# Monitoreo de Operación y SLA de Mensajería | Python, SQL & Power BI

## 📌 Descripción del Proyecto
Este proyecto analiza el flujo de mensajería transaccional y la eficiencia operativa de canales de atención al cliente. Se procesaron registros crudos con Python y SQL para evaluar tasas de entrega, cuellos de botella en la atención (SLA) y comportamiento de usuarios por franjas horarias, culminando en un dashboard ejecutivo en Power BI con recomendaciones operativas y arquitectura de escalabilidad FinOps.

---

## 🛠️ Stack Tecnológico
* **ETL & Data Cleaning:** Python (Pandas, Regex)
* **Base de Datos & Modelado:** MySQL, DBeaver (CTEs, Window Functions)
* **Visualización & KPIs:** Power BI (Import Mode, DAX)
* **Arquitectura:** Plan de escalabilidad con Power BI Service & Carga Incremental

---

## 📊 Principales Métricas e Indicadores
* **SLA de Respuesta:** Evaluación de tiempos de espera con foco en el pico crítico de las 10 PM (884 min).
* **Efectividad del Canal:** Tasa de entrega (*Delivered vs. Failed*) y volumen de mensajes salientes.
* **Segmentación de Demanda:** Clasificación de solicitudes entre Consultas Generales y Peticiones/Quejas.

---

## 🚀 Acciones de Negocio Recomendadas
1. **Atención Prioritaria:** Implementación de cola prioritaria para Peticiones/Quejas con alto impacto en la insatisfacción.
2. **Rebalanceo Operativo:** Redistribución de turnos en franjas pico nocturnas para mitigar el represamiento.
3. **Optimización FinOps:** Implementación de refresco incremental para optimizar costos de licenciamiento e infraestructura.
