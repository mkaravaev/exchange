# Exchange


## README

1. Specs are wrong for `&send_instruction/2` in given assigment
    1.1 {:ok} is so wired to return, changed to :ok
    1.2 {:error, reason: any()}, changed to {:error, any()}
    1.3 args is different in spec and example, changed as in example 

2. Data structures chosen for the task
    2.1 We should use separate storage for :ask and :bid instuctions storage.
    2.2 I choose ETS :set table as it gives us O(1) for read and write

3. App Design
  * Exchange (API module) - GenServer that holds Storage as state
  * Storage - Behaviour for CRUD operations
  * Query - API for Storage



