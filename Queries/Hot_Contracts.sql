-- ad065633-1e1d-4e28-a3dd-9f8c53724b73
-- forked from Top Contracts Raw @ https://flipsidecrypto.xyz/edit/queries/4451ac96-3a96-41db-b275-3c3cd07d1339

WITH contracts AS (
  SELECT
    CONTRACT_ADDRESS AS contract,
    COALESCE(IFNULL(CONTRACT_NAME, ADDRESS_NAME), '-') AS program,
    TOTAL_FEE AS total_fees_paid
  FROM (
    SELECT
      value [0] :: string AS CONTRACT_ADDRESS,
      value [1] :: string AS SYMBOL,
      value [2] :: string AS CONTRACT_NAME,
      value [3] :: string AS TOTAL_FEE
    FROM(
      SELECT livequery.live.udf_api(
          'https://flipsidecrypto.xyz/api/queries/4451ac96-3a96-41db-b275-3c3cd07d1339/latest-run'
      ) AS response), LATERAL FLATTEN (input => response:data:data)
    )
    LEFT JOIN ethereum.core.dim_labels on CONTRACT_ADDRESS = ADDRESS
), top_Contracts AS (
  SELECT
    a.contract,
    a.program,
    b.CREATED_BLOCK_TIMESTAMP AS created_at,
    a.total_fees_paid
  FROM
    contracts a
  LEFT JOIN ethereum.core.dim_contracts b
  ON a.contract = b.ADDRESS
)

SELECT * FROM top_contracts
ORDER BY total_fees_paid DESC