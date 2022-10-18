--P1
CREATE OR REPLACE PROCEDURE MODIFSTOCKPRODUIT (IdProd_ NUMBER, Quantite_ NUMBER) 
IS
BEGIN
UPDATE Produit SET QuantiteStock = (QuantiteStock + Quantite_) WHERE IdProd = IdProd_;
END;
/

--F1
CREATE OR REPLACE FUNCTION QuantiteRestante(IdProd_ INTEGER) RETURN INTEGER
IS
Stock INTEGER;
BEGIN
SELECT QUANTITESTOCK INTO Stock FROM PRODUIT WHERE IdProd = IdProd_;
RETURN Stock;
END;
/

--P2
CREATE OR REPLACE PROCEDURE AJOUTNOUVCOMMANDE (IdClient_ INTEGER, IdProd_ INTEGER, Quantite_ NUMBER) 
IS
BEGIN
IF (QuantiteRestante(IdProd_) >= Quantite_) THEN
    
    INSERT INTO COMMANDE(IdCommande, IdClient, IdProd, QuantiteCommande, DateCommande) 
    VALUES (SeqCommande.NEXTVAL, IdClient_, IdProd_, Quantite_, SYSDATE);
    MODIFSTOCKPRODUIT(IdProd_, -Quantite_);   
ELSE    
    dbms_output.put_line  ('Stock Insuffisant'); 
    
END IF;
END;
/

--F2
CREATE OR REPLACE FUNCTION getIdProduit(idCommande_ INTEGER) RETURN INTEGER
IS
findProduct INTEGER;
BEGIN
SELECT IdProd INTO findProduct FROM COMMANDE WHERE idCommande = idCommande_;
RETURN findProduct;
END;
/

--P3
CREATE OR REPLACE PROCEDURE ANNULECOMMANDE(IdCom_ INTEGER)
IS
BEGIN
MODIFSTOCKPRODUIT(getIdProduit(IdCom_), QuantiteRestante(getIdProduit(IdCom_)));
DELETE FROM COMMANDE WHERE IdCommande = IdCom_;
END;
/

--F3
CREATE OR REPLACE FUNCTION getIdClient(idCommande_ INTEGER) RETURN INTEGER
IS
findClient INTEGER;
BEGIN
SELECT IdClient INTO findClient FROM COMMANDE WHERE idCommande = idCommande_;
RETURN findClient;
END;
/

--P4
CREATE OR REPLACE PROCEDURE MAJQUANTITECOMMANDE(IdCom_ INTEGER, Value_ NUMBER)
IS
idProduit_ INTEGER;
idClient_ INTEGER;
BEGIN
idProduit_ := getIdProduit(IdCom_);
idClient_ := getIdClient(IdCom_);
ANNULECOMMANDE(IdCom_);
AJOUTNOUVCOMMANDE(idProduit_, idClient_, Value_);
END;
/

--F4
CREATE OR REPLACE FUNCTION CLIENTCOMMANDE (IdCom_ INTEGER) RETURN VARCHAR
IS
Nom VARCHAR(50);
Prenom VARCHAR(50);
BEGIN
SELECT NomClient INTO Nom FROM CLIENT WHERE IdClient = getIdClient(IdCom_);
SELECT PrenomClient INTO Prenom FROM CLIENT WHERE IdClient = getIdClient(IdCom_);
RETURN Nom || ' ' || Prenom;
END;
/

--F5
CREATE OR REPLACE FUNCTION CLIENTCA (IdClient_ INTEGER) RETURN NUMBER
IS
CA NUMBER;
BEGIN
SELECT Sum(QuantiteCommande*PrixProd) INTO CA 
FROM PRODUIT INNER JOIN COMMANDE ON Produit.IdProd = Commande.IdProd
WHERE Commande.IdClient = IdClient_;
RETURN CA;
END;
/

--P5
CREATE OR REPLACE PROCEDURE AfficheClient
IS
BEGIN
FOR TUPLE IN (SELECT * FROM CLIENT) loop 
dbms_output.put_line('Le Client ' || Tuple.NomClient || ' ' || Tuple.PrenomClient || ' a un chiffre d affaire de ' || ClientCA(Tuple.IdClient) || '€');
END LOOP;
END;
/