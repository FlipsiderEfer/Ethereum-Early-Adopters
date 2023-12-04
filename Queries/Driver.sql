-- Query ID: a1f26474-2b22-468e-91e7-e232be54eaff

WITH queries AS (
  SELECT
    '110377d7-370b-4738-89ea-1e4c08292fcf' AS a,
    '7a3c0a8b-ecb9-45a7-9a58-a920a1c87b6f' AS b,
    '54da60e0-8dc8-4164-a39b-72cc3153a0b9' AS c,
    'a27b1ad3-fa8f-4373-a3ca-61401d2cacac' AS d
), address AS (
  SELECT LOWER('{{Address}}') AS addr
), address_query AS (
  SELECT
    CASE
      WHEN (SELECT addr FROM address) LIKE '0x0%' THEN (SELECT a FROM queries)
      WHEN (SELECT addr FROM address) LIKE '0x1%' THEN (SELECT a FROM queries)
      WHEN (SELECT addr FROM address) LIKE '0x2%' THEN (SELECT a FROM queries)
      WHEN (SELECT addr FROM address) LIKE '0x3%' THEN (SELECT a FROM queries)
      WHEN (SELECT addr FROM address) LIKE '0x4%' THEN (SELECT b FROM queries)
      WHEN (SELECT addr FROM address) LIKE '0x5%' THEN (SELECT b FROM queries)
      WHEN (SELECT addr FROM address) LIKE '0x6%' THEN (SELECT b FROM queries)
      WHEN (SELECT addr FROM address) LIKE '0x7%' THEN (SELECT b FROM queries)
      WHEN (SELECT addr FROM address) LIKE '0x8%' THEN (SELECT c FROM queries)
      WHEN (SELECT addr FROM address) LIKE '0x9%' THEN (SELECT c FROM queries)
      WHEN (SELECT addr FROM address) LIKE '0xa%' THEN (SELECT c FROM queries)
      WHEN (SELECT addr FROM address) LIKE '0xb%' THEN (SELECT c FROM queries)
      WHEN (SELECT addr FROM address) LIKE '0xc%' THEN (SELECT d FROM queries)
      WHEN (SELECT addr FROM address) LIKE '0xd%' THEN (SELECT d FROM queries)
      WHEN (SELECT addr FROM address) LIKE '0xe%' THEN (SELECT d FROM queries)
      WHEN (SELECT addr FROM address) LIKE '0xf%' THEN (SELECT d FROM queries)
    END AS query_type
), response AS (
  SELECT live.udf_api(
    CONCAT(
        'https://flipsidecrypto.xyz/api/queries/',
        (SELECT query_type FROM address_query),
        '/latest-run'
    )
  ) as raw
), result AS (
  SELECT
    value[0]::STRING as user,
    value[1]::STRING AS quantity
  FROM
    response, LATERAL FLATTEN(input => PARSE_JSON(raw:data:data))
  WHERE
    user=(SELECT addr FROM address)
)

SELECT
  (SELECT addr FROM address) AS user,
  COALESCE((SELECT quantity FROM result), '<4') AS number_of_contracts,
  CASE
    WHEN number_of_contracts = '<4' THEN '❌'
    ELSE '✅'
  END AS eth_early_adopter
