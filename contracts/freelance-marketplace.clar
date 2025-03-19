;; Title: BitHive - Decentralized Freelance Marketplace
;; 
;; Summary:
;; A trustless freelance marketplace built on Stacks, leveraging Bitcoin's security.
;; Enables secure freelance transactions with milestone-based payments, dispute resolution,
;; and reputation management.
;;
;; Description:
;; BitHive revolutionizes freelancing by providing:
;; - Escrow-backed job contracts with milestone-based payments
;; - Transparent bidding system
;; - Decentralized dispute resolution
;; - Reputation tracking for freelancers and clients
;; - Direct integration with STX for secure payments
;; Built on Stacks L2, ensuring scalability while inheriting Bitcoin's security guarantees.

;; Constants and Error Codes
(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-INVALID-JOB (err u101))
(define-constant ERR-INVALID-STATUS (err u102))
(define-constant ERR-INSUFFICIENT-FUNDS (err u103))
(define-constant ERR-ALREADY-BIDDED (err u104))
(define-constant ERR-DISPUTE-EXISTS (err u105))

;; Data Variables
(define-data-var job-counter uint u0)

;; Data Maps
(define-map jobs
	{ job-id: uint }
	{
		client: principal,
		title: (string-utf8 100),
		description: (string-utf8 500),
		budget: uint,
		status: (string-utf8 20),
		freelancer: (optional principal),
		milestones: (list 10 uint),
		current-milestone: uint
	}
)

(define-map bids
    { job-id: uint, bidder: principal }
    {
        amount: uint,
        proposal: (string-utf8 500),
        status: (string-utf8 20)
    }
)

(define-map user-ratings
    { user: principal }
    {
        total-rating: uint,
        number-of-ratings: uint,
        average-rating: uint
    }
)

(define-map disputes
    { job-id: uint }
    {
        initiator: principal,
        reason: (string-utf8 500),
        votes-release: uint,
        votes-refund: uint,
        resolved: bool
    }
)

(define-map escrow
    { job-id: uint }
    {
        amount: uint,
        locked: bool
    }
)

;; Job Management Functions

(define-public (post-job (title (string-utf8 100)) (description (string-utf8 500)) (budget uint) (milestones (list 10 uint)))
    (let
        (
            (job-id (+ (var-get job-counter) u1))
        )
        (try! (stx-transfer? budget tx-sender (as-contract tx-sender)))
        (map-set jobs
            { job-id: job-id }
            {
                client: tx-sender,
                title: title,
                description: description,
                budget: budget,
                status: "open",
                freelancer: none,
                milestones: milestones,
                current-milestone: u0
            }
        )
        (var-set job-counter job-id)
        (map-set escrow
            { job-id: job-id }
            {
                amount: budget,
                locked: true
            }
        )
        (ok job-id)
    )
)

(define-public (place-bid (job-id uint) (amount uint) (proposal (string-utf8 500)))
    (let
        (
            (job (unwrap! (map-get? jobs { job-id: job-id }) (err u404)))
        )
        (asserts! (is-eq (get status job) "open") ERR-INVALID-STATUS)
        (asserts! (is-none (map-get? bids { job-id: job-id, bidder: tx-sender })) ERR-ALREADY-BIDDED)

        (map-set bids
            { job-id: job-id, bidder: tx-sender }
            {
                amount: amount,
                proposal: proposal,
                status: "pending"
            }
        )
        (ok true)
    )
)