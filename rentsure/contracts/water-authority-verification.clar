;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Constants and Error Codes
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define-constant ERR-NOT-AUTHORIZED u100)
(define-constant ERR-ALREADY-VERIFIED u101)
(define-constant ERR-NOT-FOUND u102)
(define-constant ERR-CANNOT-REMOVE-SELF u103)
(define-constant ERR-INVALID-ADMIN u104)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Data Variables and Maps
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define-data-var admin principal tx-sender)

(define-map verified-authorities principal bool)
(define-map authority-added-at principal uint)
(define-map authority-added-by principal principal)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Internal Utility Functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define-private (is-admin (who principal))
  (is-eq who (var-get admin)))

(define-private (not-eq (a principal) (b principal))
  (not (is-eq a b)))

(define-read-only (get-admin)
  (ok (var-get admin)))

(define-read-only (get-authority-added-at (who principal))
  (match (map-get? authority-added-at who)
    value (ok value)
    (err ERR-NOT-FOUND)))

(define-read-only (get-authority-added-by (who principal))
  (match (map-get? authority-added-by who)
    value (ok value)
    (err ERR-NOT-FOUND)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Public Functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define-public (add-authority (authority principal))
  (begin
    (asserts! (is-admin tx-sender) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-none (map-get? verified-authorities authority)) (err ERR-ALREADY-VERIFIED))
    (map-set verified-authorities authority true)
    (map-set authority-added-at authority block-height)
    (map-set authority-added-by authority tx-sender)
    (ok true)))

(define-public (remove-authority (authority principal))
  (begin
    (asserts! (is-admin tx-sender) (err ERR-NOT-AUTHORIZED))
    (asserts! (not (is-eq tx-sender authority)) (err ERR-CANNOT-REMOVE-SELF))
    (asserts! (is-some (map-get? verified-authorities authority)) (err ERR-NOT-FOUND))
    (map-delete verified-authorities authority)
    (map-delete authority-added-at authority)
    (map-delete authority-added-by authority)
    (ok true)))

(define-public (transfer-admin (new-admin principal))
  (begin
    (asserts! (is-admin tx-sender) (err ERR-NOT-AUTHORIZED))
    (asserts! (not-eq tx-sender new-admin) (err ERR-INVALID-ADMIN))
    (var-set admin new-admin)
    (ok true)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Read-Only Functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define-read-only (is-verified-authority (who principal))
  (default-to false (map-get? verified-authorities who)))

(define-read-only (list-authority-meta (who principal))
  (ok {
    verified: (default-to false (map-get? verified-authorities who)),
    added-at: (map-get? authority-added-at who),
    added-by: (map-get? authority-added-by who)
  }))

