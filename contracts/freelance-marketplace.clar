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