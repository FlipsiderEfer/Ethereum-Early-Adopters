-- Query ID: 4451ac96-3a96-41db-b275-3c3cd07d1339
-- forked from https://flipsidecrypto.xyz/MoDeFi/q/_s9UNlAAoJ8i/eth-top-contracts-raw on Sun Dec 3, 16:47:47 UTC

WITH raw AS (
  SELECT
    *
  from
    (
      SELECT
        ADDRESS,
        SYMBOL,
        NAME,
        SUM(TX_FEE) AS fee
      FROM
        ethereum.core.fact_transactions a
      JOIN ethereum.core.dim_contracts b
        ON ADDRESS = FROM_ADDRESS
        OR ADDRESS = TO_ADDRESS
      WHERE
        TO_ADDRESS = ADDRESS
      GROUP BY
        1, 2, 3
    )
  WHERE
    fee >= 100
)

SELECT * FROM RAW