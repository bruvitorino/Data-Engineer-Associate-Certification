-- Contornando erro de valores nulos em game_id, colocando -1 onde os valores são nulos
-- Colocando index porque tem no csv baixado 
CREATE TABLE games(
	index INT,
	game_id INT PRIMARY KEY,
	game_type VARCHAR(10)
);

CREATE TABLE users (
	index INTEGER, 
	user_id INT PRIMARY KEY, 
	age INT, 
	registration_date DATE, 
	email VARCHAR(50), 
	workout_frequency VARCHAR(15)
);
	
CREATE TABLE devices (
	index INTEGER, 
	device_id INT PRIMARY KEY, 
	device_name VARCHAR(10), 
	version VARCHAR(10)
);
	
CREATE TABLE events (
    index INTEGER,
    event_id INT PRIMARY KEY,
    game_id INT REFERENCES games(game_id),
    device_id INT REFERENCES devices(device_id),
    user_id INT REFERENCES users(user_id),
    event_time TIMESTAMP
);

SELECT *
FROM events;

SELECT *
FROM games;

SELECT * 
FROM devices;

SELECT *
FROM users;

SELECT *
FROM events
WHERE game_id = -1;

--retirando index pois não tem necessidade
ALTER TABLE users DROP COLUMN index;
ALTER TABLE devices DROP COLUMN index;
ALTER TABLE games DROP COLUMN index;
ALTER TABLE events DROP COLUMN index;
        
------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--TASK1
--Objetivo: Retornar um DataFrame chamado clean_data contendo dados limpos da tabela users, seguindo as especificações de formato e tratamento de valores ausentes.

--Especificações:

    --user_id: Mantido como está (integer). Não possui valores ausentes.
    --age: Integer. Valores ausentes devem ser substituídos pela média das idades.
    --registration_date: Date no formato YYYY-MM-DD. Valores ausentes devem ser substituídos por 2024-01-01.
    --email: String. Valores ausentes devem ser substituídos por 'Unknown'.
    --workout_frequency: String em lowercase, com valores possíveis: 'minimal', 'flexible', 'regular', 'maximal'. Valores ausentes devem ser substituídos por 'flexible'.

CREATE TABLE TASK1 AS
WITH AvgAge AS (
    SELECT AVG(age) AS average_age
    FROM users
)
SELECT
    u.user_id,
    COALESCE(u.age, (SELECT average_age FROM AvgAge)) AS age,
	    COALESCE(CAST(u.registration_date AS DATE), '2024-01-01') AS registration_date,
    COALESCE(u.email, 'Unknown') AS email,
    COALESCE(NULLIF(LOWER(u.workout_frequency), ''), 'flexible') AS workout_frequency
FROM users u;

--Explicação da Consulta:

    --WITH AvgAge AS (...): Criamos uma Common Table Expression (CTE) chamada AvgAge para calcular a média da coluna age da tabela users. Isso é feito para que possamos usar essa média para substituir os valores nulos sem precisar recalculá-la para cada linha.
    --SELECT ... FROM users u: Selecionamos as colunas da tabela users. Usamos o alias u para facilitar a referência.
    --COALESCE(u.age, (SELECT average_age FROM AvgAge)): A função COALESCE retorna o primeiro valor não nulo em sua lista de argumentos. Aqui, se u.age não for nulo, ele será retornado. Se for nulo, o resultado da subconsulta que busca a average_age da CTE AvgAge será usado.
    --COALESCE(CAST(u.registration_date AS DATE), '2024-01-01') AS registration_date: Primeiro, tentamos converter a coluna registration_date para o tipo DATE. Se a conversão for bem-sucedida e o valor não for nulo, ele será retornado. Se u.registration_date for nulo ou não puder ser convertido para DATE, o valor '2024-01-01' será usado.
    --COALESCE(u.email, 'Unknown') AS email: Se o valor de u.email for nulo, ele será substituído por 'Unknown'.
    --COALESCE(NULLIF(LOWER(u.workout_frequency), ''), 'flexible') AS workout_frequency: Primeiro, convertemos o valor de u.workout_frequency para lowercase usando LOWER(). Se o resultado for nulo (o que aconteceria se u.workout_frequency fosse originalmente nulo), ele será substituído por 'flexible'.

SELECT *
FROM TASK1
ORDER BY user_id ASC;
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--TASK2
--Objetivo: Atualizar a tabela events (sem modificá-la diretamente na instrução SQL, mas sim retornando um DataFrame com as alterações) para preencher os valores ausentes na coluna game_id para todos os eventos que ocorreram antes do ano de 2021.

--Informações importantes:

    --Para eventos que ocorreram antes de 2021, o game_id está ausente (nulo).
    --Sabemos que antes de 2021, existiam apenas jogos onde a coluna game_type na tabela games era igual a 'running'.
    --O game_id para esses jogos pode ser encontrado na tabela games.

--Consulta SQL:

--Precisamos selecionar todos os eventos da tabela events. Para os eventos que ocorreram antes de 2021 e têm game_id nulo, precisamos buscar o game_id correspondente da tabela games onde game_type é 'running'.
	
SELECT
    e.event_id,
    CASE
        WHEN EXTRACT(YEAR FROM e.event_time) < 2021 THEN 4 -- Substituir game_id ausente por 4 para anos anteriores a 2020
        ELSE e.game_id
    END AS game_id,
    e.device_id,
    e.user_id,
    e.event_time
FROM events e;

--WHEN EXTRACT(YEAR FROM e.event_time) < 2020 THEN 4: Agora, a substituição do game_id para 4 ocorrerá apenas para os eventos onde o ano extraído da coluna event_time é menor que 2020 (ou seja, 2019, 2018, e assim por diante).
--ELSE e.game_id: Para todos os eventos que ocorreram no ano 2020 ou posteriormente, o valor original de e.game_id será mantido.

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
--TASK3

--Objetivo: Escrever uma consulta SQL para fornecer o user_id e o event_time para usuários que participaram de eventos relacionados a jogos do tipo 'biking'. O resultado deve ser um DataFrame chamado event_biking.

--Informações importantes:

    --Precisamos identificar os eventos que estão relacionados a jogos do tipo 'biking'. Essa informação está nas tabelas events e games.
    --A tabela events possui a coluna game_id, que é uma chave estrangeira para a tabela games.
    --A tabela games possui a coluna game_type, que nos indica o tipo do jogo.

--Consulta SQL:

--Precisamos juntar as tabelas events e games usando a coluna game_id para filtrar os eventos que correspondem a jogos do tipo 'biking'. Depois, selecionaremos o user_id e o event_time desses eventos.

SELECT
    e.user_id,
    e.event_time,
	g.game_type
FROM events e
JOIN games g ON e.game_id = g.game_id
WHERE g.game_type = 'biking';

--Explicação da Consulta:

    --SELECT e.user_id, e.event_time: Selecionamos as colunas user_id e event_time da tabela events (usando o alias e).
    --FROM events e JOIN games g ON e.game_id = g.game_id: Realizamos um JOIN (junção) entre a tabela events (alias e) e a tabela games (alias g). A condição de junção é que os valores da coluna game_id sejam iguais em ambas as tabelas. Isso nos permite relacionar cada evento com o seu respectivo jogo.
    --WHERE g.game_type = 'biking': Filtramos os resultados para incluir apenas as linhas onde o valor da coluna game_type na tabela games é igual a 'biking'. Isso garante que estamos selecionando apenas os eventos que ocorreram em jogos do tipo 'biking'.

	-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--TASK4
	
--Objetivo: Escrever uma consulta SQL que retorne a contagem de usuários únicos para cada combinação de game_type e game_id. Entradas com game_type ausente (nulo) devem ser ignoradas. O resultado deve ter as colunas game_type, game_id e user_count, e o DataFrame deve ser chamado users_game.

--Informações importantes:

    --Precisamos contar usuários únicos (user_id).
    --A contagem deve ser agrupada por game_type e game_id.
    --Devemos ignorar registros onde game_type é nulo.(-1)
    --As colunas de saída devem ser game_type, game_id e user_count.

--Consulta SQL:

--Precisamos juntar as tabelas events e games para ter acesso ao game_type. Em seguida, agruparemos os resultados por game_type e game_id e contaremos os user_id distintos em cada grupo.
SELECT
    g.game_type,
    e.game_id,
    COUNT(DISTINCT e.user_id) AS user_count
FROM events e
JOIN games g ON e.game_id = g.game_id
WHERE g.game_type IS NOT NULL
  AND e.game_id <> -1 -- Adicionando a condição para excluir game_id = -1
GROUP BY g.game_type, e.game_id;

--SELECT g.game_type, e.game_id, COUNT(DISTINCT e.user_id) AS user_count: Selecionamos a coluna game_type da tabela games (alias g), a coluna game_id da tabela events (alias e) e a contagem de valores distintos da coluna user_id da tabela events, nomeando essa contagem como user_count.
--FROM events e JOIN games g ON e.game_id = g.game_id: Realizamos um JOIN entre as tabelas events e games usando a coluna game_id para relacionar eventos aos seus respectivos jogos.
--WHERE g.game_type IS NOT NULL: Filtramos os resultados para excluir quaisquer registros onde o game_type na tabela games seja nulo, conforme a instrução.
--GROUP BY g.game_type, e.game_id: Agrupamos os resultados com base nas colunas game_type e game_id. Isso fará com que a função de agregação COUNT(DISTINCT e.user_id) seja aplicada a cada combinação única dessas duas colunas.