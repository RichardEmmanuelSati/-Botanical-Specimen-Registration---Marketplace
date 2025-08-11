(define-non-fungible-token botanical-specimen uint)

(define-data-var next-specimen-id uint u1)
(define-data-var contract-owner principal tx-sender)
(define-data-var platform-fee-percent uint u5)

(define-map specimens uint {
  owner: principal,
  discoverer: principal,
  scientific-name: (string-ascii 100),
  common-name: (string-ascii 100),
  location: (string-ascii 200),
  genetic-info: (string-ascii 500),
  benefits: (string-ascii 500),
  conservation-status: (string-ascii 20),
  registered-at: uint,
  license-price: uint,
  royalty-percent: uint,
  verification-status: (string-ascii 20),
  verified-at: (optional uint)
})

(define-map licenses {specimen-id: uint, licensee: principal} {
  license-type: (string-ascii 50),
  expires-at: uint,
  paid-amount: uint,
  granted-at: uint
})

(define-map conservation-votes {specimen-id: uint, voter: principal} {
  status: (string-ascii 20),
  voted-at: uint
})

(define-map conservation-proposals uint {
  specimen-id: uint,
  proposed-status: (string-ascii 20),
  votes-for: uint,
  votes-against: uint,
  created-at: uint,
  expires-at: uint
})

(define-map bounties uint {
  specimen-id: uint,
  creator: principal,
  target-amount: uint,
  current-amount: uint,
  description: (string-ascii 500),
  created-at: uint,
  expires-at: uint
})

(define-map bounty-contributions {bounty-id: uint, contributor: principal} uint)

(define-map verification-requests uint {
  specimen-id: uint,
  requester: principal,
  created-at: uint,
  expires-at: uint,
  reviews-needed: uint,
  reviews-submitted: uint,
  approvals: uint,
  rejections: uint,
  status: (string-ascii 20)
})

(define-map peer-reviews {request-id: uint, reviewer: principal} {
  approved: bool,
  review-notes: (string-ascii 500),
  submitted-at: uint
})

(define-map reviewer-reputation principal {
  total-reviews: uint,
  accurate-reviews: uint,
  reputation-score: uint
})

(define-data-var next-proposal-id uint u1)
(define-data-var next-bounty-id uint u1)
(define-data-var next-verification-id uint u1)
(define-data-var min-reviews-required uint u3)

(define-constant err-not-authorized (err u1001))
(define-constant err-not-found (err u1002))
(define-constant err-already-exists (err u1003))
(define-constant err-invalid-amount (err u1004))
(define-constant err-expired (err u1005))
(define-constant err-insufficient-funds (err u1006))
(define-constant err-verification-required (err u1007))
(define-constant err-already-reviewed (err u1008))

(define-read-only (get-specimen (specimen-id uint))
  (map-get? specimens specimen-id))

(define-read-only (get-license (specimen-id uint) (licensee principal))
  (map-get? licenses {specimen-id: specimen-id, licensee: licensee}))

(define-read-only (get-conservation-proposal (proposal-id uint))
  (map-get? conservation-proposals proposal-id))

(define-read-only (get-bounty (bounty-id uint))
  (map-get? bounties bounty-id))

(define-read-only (get-next-specimen-id)
  (var-get next-specimen-id))

(define-read-only (get-verification-request (request-id uint))
  (map-get? verification-requests request-id))

(define-read-only (get-peer-review (request-id uint) (reviewer principal))
  (map-get? peer-reviews {request-id: request-id, reviewer: reviewer}))

(define-read-only (get-reviewer-reputation (reviewer principal))
  (map-get? reviewer-reputation reviewer))

(define-public (register-specimen 
  (scientific-name (string-ascii 100))
  (common-name (string-ascii 100))
  (location (string-ascii 200))
  (genetic-info (string-ascii 500))
  (benefits (string-ascii 500))
  (license-price uint)
  (royalty-percent uint))
  (let ((specimen-id (var-get next-specimen-id)))
    (try! (nft-mint? botanical-specimen specimen-id tx-sender))
    (map-set specimens specimen-id {
      owner: tx-sender,
      discoverer: tx-sender,
      scientific-name: scientific-name,
      common-name: common-name,
      location: location,
      genetic-info: genetic-info,
      benefits: benefits,
      conservation-status: "unknown",
      registered-at: block-height,
      license-price: license-price,
      royalty-percent: royalty-percent,
      verification-status: "pending",
      verified-at: none
    })
    (var-set next-specimen-id (+ specimen-id u1))
    (ok specimen-id)))

(define-public (purchase-license (specimen-id uint) (license-type (string-ascii 50)) (duration uint))
  (let ((specimen (unwrap! (map-get? specimens specimen-id) err-not-found))
        (license-cost (get license-price specimen))
        (platform-fee (/ (* license-cost (var-get platform-fee-percent)) u100))
        (owner-payment (- license-cost platform-fee))
        (royalty-amount (/ (* license-cost (get royalty-percent specimen)) u100))
        (discoverer-payment (- owner-payment royalty-amount)))
    (asserts! (is-eq (get verification-status specimen) "verified") err-verification-required)
    (try! (stx-transfer? license-cost tx-sender (get owner specimen)))
    (if (not (is-eq (get owner specimen) (get discoverer specimen)))
      (try! (stx-transfer? royalty-amount (get owner specimen) (get discoverer specimen)))
      true)
    (try! (stx-transfer? platform-fee tx-sender (var-get contract-owner)))
    (map-set licenses {specimen-id: specimen-id, licensee: tx-sender} {
      license-type: license-type,
      expires-at: (+ block-height duration),
      paid-amount: license-cost,
      granted-at: block-height
    })
    (ok true)))

(define-public (transfer-specimen (specimen-id uint) (new-owner principal))
  (let ((specimen (unwrap! (map-get? specimens specimen-id) err-not-found)))
    (asserts! (is-eq tx-sender (get owner specimen)) err-not-authorized)
    (try! (nft-transfer? botanical-specimen specimen-id tx-sender new-owner))
    (map-set specimens specimen-id (merge specimen {owner: new-owner}))
    (ok true)))

(define-public (create-conservation-proposal (specimen-id uint) (proposed-status (string-ascii 20)))
  (let ((proposal-id (var-get next-proposal-id)))
    (asserts! (is-some (map-get? specimens specimen-id)) err-not-found)
    (map-set conservation-proposals proposal-id {
      specimen-id: specimen-id,
      proposed-status: proposed-status,
      votes-for: u0,
      votes-against: u0,
      created-at: block-height,
      expires-at: (+ block-height u144)
    })
    (var-set next-proposal-id (+ proposal-id u1))
    (ok proposal-id)))

(define-public (vote-conservation (proposal-id uint) (vote-for bool))
  (let ((proposal (unwrap! (map-get? conservation-proposals proposal-id) err-not-found)))
    (asserts! (< block-height (get expires-at proposal)) err-expired)
    (asserts! (is-none (map-get? conservation-votes {specimen-id: (get specimen-id proposal), voter: tx-sender})) err-already-exists)
    (map-set conservation-votes {specimen-id: (get specimen-id proposal), voter: tx-sender} {
      status: (if vote-for "for" "against"),
      voted-at: block-height
    })
    (if vote-for
      (map-set conservation-proposals proposal-id (merge proposal {votes-for: (+ (get votes-for proposal) u1)}))
      (map-set conservation-proposals proposal-id (merge proposal {votes-against: (+ (get votes-against proposal) u1)})))
    (ok true)))

(define-public (execute-conservation-proposal (proposal-id uint))
  (let ((proposal (unwrap! (map-get? conservation-proposals proposal-id) err-not-found))
        (specimen-id (get specimen-id proposal)))
    (asserts! (>= block-height (get expires-at proposal)) err-not-authorized)
    (asserts! (> (get votes-for proposal) (get votes-against proposal)) err-not-authorized)
    (let ((specimen (unwrap! (map-get? specimens specimen-id) err-not-found)))
      (map-set specimens specimen-id (merge specimen {conservation-status: (get proposed-status proposal)}))
      (ok true))))

(define-public (create-bounty (specimen-id uint) (target-amount uint) (description (string-ascii 500)) (duration uint))
  (let ((bounty-id (var-get next-bounty-id)))
    (asserts! (is-some (map-get? specimens specimen-id)) err-not-found)
    (asserts! (> target-amount u0) err-invalid-amount)
    (map-set bounties bounty-id {
      specimen-id: specimen-id,
      creator: tx-sender,
      target-amount: target-amount,
      current-amount: u0,
      description: description,
      created-at: block-height,
      expires-at: (+ block-height duration)
    })
    (var-set next-bounty-id (+ bounty-id u1))
    (ok bounty-id)))

(define-public (contribute-to-bounty (bounty-id uint) (amount uint))
  (let ((bounty (unwrap! (map-get? bounties bounty-id) err-not-found)))
    (asserts! (< block-height (get expires-at bounty)) err-expired)
    (asserts! (> amount u0) err-invalid-amount)
    (let ((current-contribution (default-to u0 (map-get? bounty-contributions {bounty-id: bounty-id, contributor: tx-sender}))))
      (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
      (map-set bounty-contributions {bounty-id: bounty-id, contributor: tx-sender} (+ current-contribution amount))
      (map-set bounties bounty-id (merge bounty {current-amount: (+ (get current-amount bounty) amount)}))
      (ok true))))

(define-public (claim-bounty (bounty-id uint))
  (let ((bounty (unwrap! (map-get? bounties bounty-id) err-not-found))
        (specimen (unwrap! (map-get? specimens (get specimen-id bounty)) err-not-found)))
    (asserts! (is-eq tx-sender (get discoverer specimen)) err-not-authorized)
    (asserts! (>= (get current-amount bounty) (get target-amount bounty)) err-insufficient-funds)
    (try! (as-contract (stx-transfer? (get current-amount bounty) tx-sender (get discoverer specimen))))
    (ok true)))

(define-public (update-license-price (specimen-id uint) (new-price uint))
  (let ((specimen (unwrap! (map-get? specimens specimen-id) err-not-found)))
    (asserts! (is-eq tx-sender (get owner specimen)) err-not-authorized)
    (map-set specimens specimen-id (merge specimen {license-price: new-price}))
    (ok true)))

(define-public (request-verification (specimen-id uint))
  (let ((specimen (unwrap! (map-get? specimens specimen-id) err-not-found))
        (verification-id (var-get next-verification-id)))
    (asserts! (is-eq tx-sender (get discoverer specimen)) err-not-authorized)
    (asserts! (is-eq (get verification-status specimen) "pending") err-already-exists)
    (map-set verification-requests verification-id {
      specimen-id: specimen-id,
      requester: tx-sender,
      created-at: block-height,
      expires-at: (+ block-height u1008),
      reviews-needed: (var-get min-reviews-required),
      reviews-submitted: u0,
      approvals: u0,
      rejections: u0,
      status: "open"
    })
    (var-set next-verification-id (+ verification-id u1))
    (ok verification-id)))

(define-public (submit-peer-review (request-id uint) (approved bool) (review-notes (string-ascii 500)))
  (let ((verification-request (unwrap! (map-get? verification-requests request-id) err-not-found))
        (existing-review (map-get? peer-reviews {request-id: request-id, reviewer: tx-sender})))
    (asserts! (is-none existing-review) err-already-reviewed)
    (asserts! (< block-height (get expires-at verification-request)) err-expired)
    (asserts! (is-eq (get status verification-request) "open") err-expired)
    (map-set peer-reviews {request-id: request-id, reviewer: tx-sender} {
      approved: approved,
      review-notes: review-notes,
      submitted-at: block-height
    })
    (let ((updated-request (merge verification-request {
            reviews-submitted: (+ (get reviews-submitted verification-request) u1),
            approvals: (if approved (+ (get approvals verification-request) u1) (get approvals verification-request)),
            rejections: (if approved (get rejections verification-request) (+ (get rejections verification-request) u1))
          }))
          (current-reputation (default-to {total-reviews: u0, accurate-reviews: u0, reputation-score: u0} 
                                         (map-get? reviewer-reputation tx-sender))))
      (map-set verification-requests request-id updated-request)
      (map-set reviewer-reputation tx-sender (merge current-reputation {
        total-reviews: (+ (get total-reviews current-reputation) u1)
      }))
      (if (>= (get reviews-submitted updated-request) (get reviews-needed updated-request))
        (finalize-verification request-id)
        (ok true)))))

(define-private (finalize-verification (request-id uint))
  (let ((verification-request (unwrap! (map-get? verification-requests request-id) err-not-found))
        (specimen-id (get specimen-id verification-request))
        (specimen (unwrap! (map-get? specimens specimen-id) err-not-found)))
    (let ((final-status (if (> (get approvals verification-request) (get rejections verification-request)) "verified" "rejected")))
      (map-set specimens specimen-id (merge specimen {
        verification-status: final-status,
        verified-at: (if (is-eq final-status "verified") (some block-height) none)
      }))
      (map-set verification-requests request-id (merge verification-request {status: "completed"}))
      (ok true))))

(define-public (update-reviewer-accuracy (reviewer principal) (was-accurate bool))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) err-not-authorized)
    (let ((current-reputation (default-to {total-reviews: u0, accurate-reviews: u0, reputation-score: u0} 
                                         (map-get? reviewer-reputation reviewer))))
      (let ((new-accurate-count (if was-accurate (+ (get accurate-reviews current-reputation) u1) (get accurate-reviews current-reputation)))
            (total-reviews (get total-reviews current-reputation)))
        (if (> total-reviews u0)
          (let ((new-score (/ (* new-accurate-count u100) total-reviews)))
            (map-set reviewer-reputation reviewer (merge current-reputation {
              accurate-reviews: new-accurate-count,
              reputation-score: new-score
            }))
            (ok true))
          (ok true))))))


