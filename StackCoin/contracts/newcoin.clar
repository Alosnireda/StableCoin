;; Define a variable to store the current exchange rate (USD to stablecoin)
(define-data-var exchange-rate uint u1000) ;; Initial exchange rate as 1 stablecoin = 1 USD

;; Define a fungible token for the stablecoin
(define-fungible-token stablecoin)

;; Governance: only allow contract owner to update exchange rate
(define-constant contract-owner 'ST1G7HBCZZ6S3G3F9H5XW0A6MS7K139JNSN9GJY9)

;; Function to update the exchange rate, restricted to the contract owner
(define-public (update-exchange-rate (new-rate uint))
  (begin
    (asserts! (is-eq tx-sender contract-owner) (err u403)) ;; Error if not contract owner
    (ok (var-set exchange-rate new-rate))))

;; Function to mint stablecoins, calculates amount based on USD deposited and current exchange rate
(define-public (mint-stablecoins (usd-deposited uint))
  (let ((tokens-to-mint (divide usd-deposited (var-get exchange-rate))))
    (stx-transfer? usd-deposited tx-sender contract-owner) ;; Transfer USD equivalent in STX to the contract owner
    (mint! stablecoin tokens-to-mint tx-sender))) ;; Mint new stablecoins to user's address

;; Function to burn stablecoins and return USD, calculates USD to return based on current exchange rate
(define-public (burn-stablecoins (tokens-to-burn uint))
  (let ((usd-to-return (multiply tokens-to-burn (var-get exchange-rate))))
    (burn! stablecoin tokens-to-burn tx-sender) ;; Burn stablecoins from user's address
    (stx-transfer? usd-to-return contract-owner tx-sender))) ;; Transfer USD equivalent in STX back to user

;; Read-only function to get the current exchange rate
(define-read-only (get-exchange-rate)
  (ok (var-get exchange-rate)))
