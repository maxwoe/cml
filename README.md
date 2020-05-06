This is the accompanying code repository for the following research paper:<br/>
[Domain Specific Language for Smart Contract Development](https://swa.cs.univie.ac.at/research/publications/publication/6341/)<br/>


CML (Contract Modeling Language) 
============

CML is a high-level DSL using a declarative and imperative formalization as well as object-oriented abstractions to specify smart contracts. The language is developed in Xtext, a frameworkfor the development of programming languages and DSLs. For demonstration purposes a [CML Web Editor](https://cml.swa.univie.ac.at/) exists.

### Characteristics ###

CML is a smart contract DSL providing a simple expression language to describe contract
computation and is designed according to principles of object oriented
programming. Being a high-level domain specific language it can be used
to generate platform specific smart contract code whilst including
common coding practices and smart contract design patterns. The basic
structure of a CML contract is similar to a class in object
oriented programming and thus consists of state variables and actions
(functions), which read and modify these. In addition, a contract
contains clauses, which mimic and capture contractual obligations in a
standardized natural-language-like way. They specify the context under
which the actions (functions) are to be called, meaning they combine
different aspects that influence action execution. In its most
simplistic form a clause specifies the obligation, or permission of a
party to execute a specific action (function).

### Type System ###

The simplest of types are primitive types which describe the various
kinds of atomic values allowed in CML. These include *Boolean*,
*String*, *Integer*, *Real*, *DateTime*, and *Duration*. The last two
types represent the basic temporal concepts of absolute and relative
time, needed to express temporal constraints and relationships typically
encountered in contracts. CML includes predefined and easily extensible
structural composite types, to embody common contract-specific concepts.
These include *Party*, *Asset*, *Transaction*, and *Event*. *Party*
denotes an individual or organization with an unique identifier that
participates in a contract. *Asset* describes a resource (long-lived
identifiable item) with a certain economic value. *Transaction* is used
to describe a message that is submitted by a party along contract
interaction. *Event* characterizes anything that happens, being either
important or unusual. In addition, a few special variables (*caller*,
*anyone*, *now*, *contractStart*, *contractEnd*) are defined which are
always present and often needed during contract definition.

### Clause Structure ###

As mentioned before, CML introduces clauses as syntactical elements. A
simplified illustration of the clause syntax is given below. Each clause has an unique identifier for referencing and
must contain at least an actor, an action (referring to a function
name), and the modality of this action (“may” or “must”). Optional
elements include temporal or general constraints. Temporal constrains
are indicated by the keyword “due” followed by a temporal precedence
statement (“after”, “before”) and a trigger expression. The trigger
expression refers to an absolute time or a construct from which an
absolute time can be deduced. This includes the performance of a clause,
the execution of an action, or the occurrence of an external event.
Additionally, the “due” statement can be enriched by a duration
statement (“within”) to further specify the considered time-frame of an
obligation. General constraints can be defined after the keyword “given”
by multiple linked conditions that evaluate to true or false.

**clause** ID\
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;\[**due** \[**within** RT\] \[**every** RT **from** AT **to** AT\] (**afterbefore**) TRIGGER\]\
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;\[**given** CONDITION\] \
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;**party** ACTOR\
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;(**maymust**) ACTION {(**and | or | xor**) ACTION}

--

Trigger:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;AT | ClauseTrigger | EventTrigger |  ActionTrigger \
ClauseTrigger:&nbsp;&nbsp;**clause** ID (**fulfilledfailed**) \
ActionTrigger:&nbsp;&nbsp;ACTOR **did** ACTION \
EventTrigger:&nbsp;&nbsp;&nbsp;&nbsp;**event** ID

RT...Relative Time, AT...Absolute Time 

### CML Example Contract ###

Given this short feature description, we can analyze a
code example. First, the namespace (line 1) and a design pattern
annotation (line 5) with its dependency (line 3) are specified, before
the contract is defined in which several state variables are declared
(line 7-9), followed by the clause statements (line 11-24), a
constructor like initzializer (line 26), and the actual contract actions
(line 29 onward). The special action is a constructor-like initzializer,
which is run during the creation of the contract and cannot be called
afterwards. It sets the vault user to the individual creating the
contract (). The remaining actions actually serve for contract
interaction and can be called by contract participants (in this case the
vault user) under the specified conditions set in the clause statements.
The action (line 29) sets the deposit value to the amount sent along the
action invocation and the unlock date for the time lock, while utilizing
several preliminary checks to ensure that a valid amount is sent and no
previous deposits exist. The action (line 39) can be used to extend the
lock time by a specified duration and the action transfers the deposited
amount back to the vault user while setting the deposit value back to
zero. The specified annotation at the beginning of the contract declares
that every outgoing transfer from the contract must occur asynchronously
for safety reasons (because the send operation can fail). This means
that if a contract sends money to another party, it is deposited for
collection and the recipient must actively withdraw the money. This
process is abstracted and implicitly applied behind the scenes for every
transfer operation, provided the annotation is used.

```
namespace cml.examples

import cml.generator.annotation.solidity.*

@PullPayment
contract TimeLock
	Party vaultUser
	DateTime unlockDate
	Integer value
	
	clause Deposit
		party vaultUser
		may deposit
		
	clause IncreaseLockTime
		due after vaultUser did deposit
		party vaultUser
		may increaseLockTime
	
	clause Withdraw
		due after vaultUser did deposit
		given now.isAfter(unlockDate)
		party vaultUser
		may withdraw

	action init()
		vaultUser = caller
		
	action deposit(TokenTransaction t)
		ensure(t.amount > 0, "Sent amount is invalid.")
		ensure(value == 0, "Deposit already exists.")
		vaultUser.deposit(value)
		value = t.amount
		unlockDate = now.addDuration(24 hours)
		
	action increaseLockTime(Duration duration)
		unlockDate = unlockDate.addDuration(duration)
		
	action withdraw()
		transfer(vaultUser, value)
		value = 0
```

### Further Example Contracts ###

```
namespace cml.examples

import cml.generator.annotation.solidity.*

@PullPayment
contract SimpleAuction
	Integer reservePrice
	Integer highestBid
	Party highestBidder
	Party beneficiary
	Party auctioneer
	Duration biddingTime
	Boolean aborted
	Boolean ended
	
	clause Bid
		due within biddingTime after contractStart
		given !aborted
		party anyone
		may bid
		
	clause AuctionEndAccept
		due after contractStart.addDuration(biddingTime)
		given !ended
		party beneficiary
		may acceptAuction
	
	clause AuctionEndReject
		due within 48 hours after contractStart.addDuration(biddingTime)
		given !ended and highestBid < reservePrice
		party beneficiary
		may rejectAuction
		
	clause AuctionAbort
		due within biddingTime after contractStart
		given !aborted
		party auctioneer
		may abortAuction
		
	action init(Duration _time, Integer _reservePrice, Party _beneficiary)
		auctioneer = caller
		reservePrice = _reservePrice
		biddingTime = _time
		beneficiary = _beneficiary

	action bid(TokenTransaction t)
		ensure(t.amount > highestBid, "There already is a higher bid.")
		caller.deposit(t.amount)
		if (highestBid != 0)
			transfer(highestBidder, highestBid)
		highestBidder = caller
		highestBid = t.amount

	action acceptAuction()
		ended = true
		transfer(beneficiary, highestBid)
	
	action rejectAuction()
		ended = true
		transfer(highestBidder, highestBid)
	
	action abortAuction()
		aborted = true
		transfer(highestBidder, highestBid)
```

```
namespace cml.examples

import cml.generator.annotation.solidity.*

@PullPayment
contract Purchase
	Integer value
	Party seller
	Party buyer
		
	clause Abort
		due before buyer did confirmPurchase
		party seller
		may abort
		
	clause ConfirmPurchase
		due within 7 days after contractStart
		party anyone
		may confirmPurchase

	clause ConfirmReceived
		due after buyer did confirmPurchase
		party buyer
		may confirmReceived
	
	clause RefundSeller
		due after buyer did confirmReceived
		party seller
		may fetchRefund
	
	action init(TokenTransaction t)
		ensure(t.amount % 2 == 0, "Value has to be even.")
		caller.deposit(t.amount)
		seller = caller
		value = t.amount / 2
		
	action abort()
		transfer(seller, token.quantity)
		
	action confirmPurchase(TokenTransaction t)
		ensure(t.amount == 2 * value, "Invalid amount submitted.")
		caller.deposit(t.amount)
		buyer = caller

	action confirmReceived()
		transfer(buyer, value)

	action fetchRefund()
		transfer(seller, 3 * value)
```
