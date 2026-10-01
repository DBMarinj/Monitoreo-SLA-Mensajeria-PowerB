use db_messaging;

select * 
from fact_mensajes;

select nombre_plantilla
from fact_mensajes;

select categoria_incoming from fact_mensajes;

SELECT categoria_incoming, COUNT(*) 
FROM fact_mensajes 
WHERE message_type = 'incoming'
GROUP BY categoria_incoming;

SELECT *
FROM fact_mensajes
WHERE categoria_incoming IS NOT NULL 
  AND categoria_incoming != 'None';


select status
from fact_mensajes;



SELECT 
    status,
    COUNT(*) AS total_mensajes,
    CONCAT(ROUND(COUNT(*) / (SELECT COUNT(*) FROM fact_mensajes WHERE message_type = 'outgoing' AND status IN ('read', 'delivered', 'failed')) * 100, 1), '%') AS porcentaje
FROM fact_mensajes
WHERE message_type = 'outgoing'
  AND status IN ('read', 'delivered', 'failed')
GROUP BY status
ORDER BY total_mensajes DESC;





-- Consulta Funnel de Entrega (Mensajes Outgoing)
SELECT 
    status,
    COUNT(*) AS total_mensajes,
    CONCAT(ROUND((COUNT(*) * 100.0) / SUM(COUNT(*)) OVER(), 2), '%') AS porcentaje
FROM fact_mensajes
WHERE message_type = 'outgoing'
  AND status IN ('read', 'delivered', 'failed')
GROUP BY status
ORDER BY total_mensajes DESC;



-- Consulta Funnel de Entrega (Mensajes Outgoing) cte
WITH MensajesFiltrados AS (
    SELECT status
    FROM fact_mensajes
    WHERE message_type = 'outgoing'
      AND status IN ('read', 'delivered', 'failed')
)
SELECT 
    status,
    COUNT(*) AS total_mensajes,
    CONCAT(ROUND((COUNT(*) * 100.0) / SUM(COUNT(*)) OVER(), 2), '%') AS porcentaje
FROM MensajesFiltrados
GROUP BY status
ORDER BY total_mensajes DESC;



-- SLA de Respuesta Operativa (Window Functions)
WITH MensajesOrdenados AS (
    SELECT 
        id,
        conversation_id,
        message_type,
        created_at,
        LEAD(created_at) OVER (
            PARTITION BY conversation_id 
            ORDER BY created_at
        ) AS fecha_respuesta,
        LEAD(message_type) OVER (
            PARTITION BY conversation_id 
            ORDER BY created_at
        ) AS tipo_respuesta
    FROM fact_mensajes
)
SELECT 
    ROUND(AVG(TIMESTAMPDIFF(SECOND, created_at, fecha_respuesta)) / 60.0, 2) AS sla_promedio_minutos,
    ROUND(MIN(TIMESTAMPDIFF(SECOND, created_at, fecha_respuesta)) / 60.0, 2) AS respuesta_mas_rapida_min,
    ROUND(MAX(TIMESTAMPDIFF(SECOND, created_at, fecha_respuesta)) / 60.0, 2) AS respuesta_mas_lenta_min,
    COUNT(*) AS total_interacciones_medidas
FROM MensajesOrdenados
WHERE message_type = 'incoming' 
  AND tipo_respuesta IN ('outgoing', 'activity');


-- SLA de Respuesta Operativa CTE y Window Functions
WITH TiemposRespuesta AS (
    SELECT 
        conversation_id,
        created_at AS fecha_respuesta,
        message_type AS tipo_respuesta,
        LAG(created_at) OVER(PARTITION BY conversation_id ORDER BY created_at) AS fecha_incoming,
        LAG(message_type) OVER(PARTITION BY conversation_id ORDER BY created_at) AS tipo_anterior
    FROM fact_mensajes
)
SELECT 
	conversation_id,
    ROUND(AVG(TIMESTAMPDIFF(MINUTE, fecha_incoming, fecha_respuesta)), 2) AS sla_promedio_minutos,
    MIN(TIMESTAMPDIFF(MINUTE, fecha_incoming, fecha_respuesta)) AS respuesta_mas_rapida_min,
    MAX(TIMESTAMPDIFF(MINUTE, fecha_incoming, fecha_respuesta)) AS respuesta_mas_lenta_min,
    COUNT(*) AS total_interacciones_medidas
FROM TiemposRespuesta
WHERE tipo_anterior = 'incoming' 
  AND tipo_respuesta IN ('outgoing', 'activity')
group by conversation_id;


USE db_messaging;

CREATE OR REPLACE VIEW vw_sla_tiempos_respuesta AS
WITH TiemposRespuesta AS (
    SELECT 
        conversation_id,
        created_at AS fecha_respuesta,
        message_type AS tipo_respuesta,
        LAG(created_at) OVER(PARTITION BY conversation_id ORDER BY created_at) AS fecha_incoming,
        LAG(message_type) OVER(PARTITION BY conversation_id ORDER BY created_at) AS tipo_anterior
    FROM fact_mensajes
)
SELECT 
    conversation_id,
    ROUND(AVG(TIMESTAMPDIFF(MINUTE, fecha_incoming, fecha_respuesta)), 2) AS sla_promedio_minutos,
    MIN(TIMESTAMPDIFF(MINUTE, fecha_incoming, fecha_respuesta)) AS respuesta_mas_rapida_min,
    MAX(TIMESTAMPDIFF(MINUTE, fecha_incoming, fecha_respuesta)) AS respuesta_mas_lenta_min,
    COUNT(*) AS total_interacciones_medidas
FROM TiemposRespuesta
WHERE tipo_anterior = 'incoming' 
  AND tipo_respuesta IN ('outgoing', 'activity')
GROUP BY conversation_id;




-- 	Curva de Calor Horaria CTE
WITH MensajesIncoming AS (
    SELECT created_hour
    FROM fact_mensajes
    WHERE message_type = 'incoming'
)
SELECT 
    created_hour AS hora_del_dia,
    COUNT(*) as total_mensajes_incoming,
    CONCAT(ROUND((COUNT(*) * 100.0) / SUM(COUNT(*)) OVER(), 2), '%') AS porcentaje_del_total
FROM MensajesIncoming
GROUP BY created_hour
ORDER BY created_hour ASC;


-- misma consulta pero con funtion window
SELECT 
    created_hour AS hora_del_dia,
    COUNT(*) AS total_mensajes_incoming,
    ROUND((COUNT(*) * 100.0) / SUM(COUNT(*)) OVER(), 2) AS porcentaje_del_total
FROM fact_mensajes
WHERE LOWER(TRIM(message_type)) = 'incoming'
GROUP BY created_hour
ORDER BY created_hour ASC;

select * from db_messaging;
