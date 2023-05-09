#include "MKL46Z4.h"
#include "lcd.h"
#include "FreeRTOS.h"
#include "task.h"
#include "queue.h"
#include "semphr.h"

int data = 0;
int productor_priority = 1;
int consumidor_priority = 2;
QueueHandle_t cola;
SemaphoreHandle_t mutex;

void irclk_ini()
{
  MCG->C1 = MCG_C1_IRCLKEN(1) | MCG_C1_IREFSTEN(1);
  MCG->C2 = MCG_C2_IRCS(0);
}

void taskProductor(void *pvParameters){
	for (;;) {
		xSemaphoreTake(mutex, portMAX_DELAY);
		data++;
		xQueueSend(cola, (void *)&data,(TickType_t) 0);
        lcd_display_dec(uxQueueMessagesWaiting(cola));
		xSemaphoreGive(mutex);
		vTaskDelay(500/portTICK_PERIOD_MS);
    }
}

void taskConsumidor(void *pvParameters){
    for (;;) {
        xSemaphoreTake(mutex, portMAX_DELAY);
        if (uxQueueMessagesWaiting(cola) > 0) {
            data--;
            xQueueReceive(cola, (void *)&data, (TickType_t) 0);
            lcd_display_dec(uxQueueMessagesWaiting(cola));
        }
        xSemaphoreGive(mutex);
        vTaskDelay(500/portTICK_PERIOD_MS);
    }
}

int main(void)
{
    irclk_ini(); // Enable internal ref clk to use by LCD
    lcd_ini();
    lcd_display_dec(0);
    cola = xQueueCreate(50, sizeof(data));
    mutex = xSemaphoreCreateMutex();

    xTaskCreate(taskProductor, (const char * const)"taskProductor", 
        configMINIMAL_STACK_SIZE, (void *)NULL, productor_priority, NULL);

    xTaskCreate(taskConsumidor, (const char * const)"taskConsumidor", 
        configMINIMAL_STACK_SIZE, (void *)NULL, consumidor_priority, NULL);

    /* start the scheduler */
    vTaskStartScheduler();
    
    while (1) {}

    return 0;
}
