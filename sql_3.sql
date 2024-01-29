CREATE TABLE Accounts (
    AccountID INT PRIMARY KEY,
    AccountNumber VARCHAR(20) UNIQUE NOT NULL,
    Balance DECIMAL(18, 2) NOT NULL
);

CREATE TABLE Transactions (
    TransactionID INT PRIMARY KEY,
    SenderAccountID INT,
    ReceiverAccountID INT,
    Amount DECIMAL(18, 2) NOT NULL,
    Status VARCHAR(10) CHECK (Status IN ('Success', 'Failed')) DEFAULT 'Success',
    FOREIGN KEY (SenderAccountID) REFERENCES Accounts(AccountID),
    FOREIGN KEY (ReceiverAccountID) REFERENCES Accounts(AccountID)
);

INSERT INTO Accounts (AccountID, AccountNumber, Balance) VALUES
(1, 'Счет 1', 1000.00),
(2, 'Счет 2', 500.00);

BEGIN TRANSACTION;

DECLARE @amount DECIMAL(18, 2) = 200.00;
DECLARE @senderAccountID INT = 1;
DECLARE @receiverAccountID INT = 2;

IF (SELECT Balance FROM Accounts WHERE AccountID = @senderAccountID) >= @amount
BEGIN
    UPDATE Accounts SET Balance = Balance - @amount WHERE AccountID = @senderAccountID;

    UPDATE Accounts SET Balance = Balance + @amount WHERE AccountID = @receiverAccountID;

    INSERT INTO Transactions (SenderAccountID, ReceiverAccountID, Amount, Status)
    VALUES (@senderAccountID, @receiverAccountID, @amount, 'Success');
END
ELSE
BEGIN
    INSERT INTO Transactions (SenderAccountID, ReceiverAccountID, Amount, Status)
    VALUES (@senderAccountID, @receiverAccountID, @amount, 'Failed');
END;

COMMIT;

SELECT * FROM Accounts;
SELECT * FROM Transactions;

