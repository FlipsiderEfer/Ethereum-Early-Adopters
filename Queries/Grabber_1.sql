-- Query ID: 110377d7-370b-4738-89ea-1e4c08292fcf

WITH response AS (
  SELECT live.udf_api(
    'https://flipsidecrypto.xyz/api/queries/ad065633-1e1d-4e28-a3dd-9f8c53724b73/latest-run'
  ) as raw
), contracts AS(
  SELECT
    value[0]::string as contract,
    value[2]::string AS program,
    value[1]::datetime AS deployment_date,
    value[3]::string AS total_fees_paid
  FROM
    response, LATERAL FLATTEN(input => PARSE_JSON(raw:data:data))
), top_contracts_users AS (
    SELECT
        contract,
        CASE 
          WHEN program IS NOT NULL AND program != '-' THEN CONCAT(program, ' (', '0x' || LEFT(contract, 3) || '***' || RIGHT(contract, 4), ')')
          ELSE '0x' || LEFT(contract, 6) || '***' || RIGHT(contract, 4)
        END AS program_mod,
        total_fees_paid,
        FROM_ADDRESS AS user,
        MIN(BLOCK_TIMESTAMP) AS min_date,
        RANK() OVER (PARTITION BY contract ORDER BY min_date ASC) AS rank
    FROM
        ethereum.core.fact_transactions a
    JOIN
        contracts b ON contract = TO_ADDRESS
    GROUP BY
        1, 2, 3, 4
), eth_og_users AS (
    SELECT
        user,
        COUNT(contract) AS contracts
        -- LISTAGG(program_mod, ' + ') WITHIN GROUP (ORDER BY program_mod) AS program_list
        -- LISTAGG(contract, ', ') WITHIN GROUP (ORDER BY contract) AS contract_list
    FROM
        top_contracts_users
    WHERE
      rank <= 1000
    AND
      (
        user LIKE '0x0%'
        OR user LIKE '0x1%'
        OR user LIKE '0x2%'
        OR user LIKE '0x3%'
      )
    GROUP BY
        1
)

SELECT user, contracts from eth_og_users
WHERE contracts >= 4
ORDER BY contracts DESC
