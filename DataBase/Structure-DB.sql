USE master
GO

IF DB_ID('CineClub') IS NOT NULL
BEGIN
    DROP DATABASE CineClub;
END
GO

CREATE DATABASE CineClub;
GO

USE CineClub
GO



-- Crea un inicio de sesión en el nivel del servidor
IF NOT EXISTS (SELECT name FROM master.sys.server_principals WHERE name = N'LoginCine')
BEGIN
    CREATE LOGIN LoginCine WITH PASSWORD = N'123';
END
GO


-- Crea un usuario de base de datos vinculado al inicio de sesión
CREATE USER UsuarioCine FOR LOGIN LoginCine;
GO

--SELECT DISTINCT p.name AS [loginname], p.type_desc, sp.permission_name
--FROM sys.server_principals p
--INNER JOIN sys.syslogins s ON p.sid = s.sid
--INNER JOIN sys.server_permissions sp ON p.principal_id = sp.grantee_principal_id
--WHERE p.type_desc IN ('SQL_LOGIN', 'WINDOWS_LOGIN', 'WINDOWS_GROUP')
--ORDER BY p.name;
--GO


-- Asigna roles al usuario
ALTER ROLE db_datareader ADD MEMBER UsuarioCine;
ALTER ROLE db_datawriter ADD MEMBER UsuarioCine;
ALTER ROLE db_ddladmin ADD MEMBER UsuarioCine;
GO

IF SCHEMA_ID('GestionCine') IS NOT NULL
BEGIN
    DROP SCHEMA GestionCine
END
GO
--El schema Cine será para las tablas Cine,Categoria,TipoSala,Sala,
CREATE SCHEMA GestionCine AUTHORIZATION dbo
GO

IF SCHEMA_ID('Consesiones') IS NOT NULL
BEGIN
    DROP SCHEMA Consesiones
END
GO
--Será para todo lo que tiene que ver con dulceria y cosas externas
CREATE SCHEMA Consesiones AUTHORIZATION dbo
GO

IF SCHEMA_ID('Usuario') IS NOT NULL
BEGIN
    DROP SCHEMA Usuario
END
GO

CREATE SCHEMA Usuario AUTHORIZATION UsuarioCine
GO

IF OBJECT_ID('Usuario.Cuenta','U') IS NOT NULL
BEGIN
	DROP TABLE Usuario.Cuenta
END
GO

CREATE TABLE Usuario.Cuenta
(
	IdCuenta	CHAR(6)	PRIMARY KEY,
	Nombres		VARCHAR(35)	NOT NULL,
	Apellidos	VARCHAR(35) NOT NULL,
	DNI			CHAR(8)		NOT NULL,

	CONSTRAINT CHK_IdCuenta CHECK (IdCuenta LIKE 'CUE[0-9][0-9][0-9]') ,
	CONSTRAINT UQ_DNI UNIQUE (DNI)
)
GO

IF OBJECT_ID('GestionCine.Tipo','U') IS NOT NULL
BEGIN
	DROP TABLE GestionCine.Tipo
END
GO

CREATE TABLE GestionCine.Tipo
(
	IdTipo	INT PRIMARY KEY,
	Descripcion	VARCHAR(20)
)
GO

IF OBJECT_ID('GestionCine.CategoriaPeli','U') IS NOT NULL
BEGIN
	DROP TABLE GestionCine.CategoriaPeli
END
GO

CREATE TABLE GestionCine.CategoriaPeli
(
	IdCategoriaPeli	CHAR(6)	PRIMARY KEY,
	Descripcion	VARCHAR(40)	NOT NULL,	

	CONSTRAINT CHK_IdCategoriaPeli CHECK (IdCategoriaPeli LIKE 'CAT[0-9][0-9][0-9]')
)
GO

IF OBJECT_ID('GestionCine.Pelicula','U') IS NOT NULL
BEGIN
	DROP TABLE GestionCine.Pelicula
END
GO

CREATE TABLE GestionCine.Pelicula
(
	IdPelicula	CHAR(6)	PRIMARY KEY,
	IdCategoriaPeli	CHAR(6),
	Nombre	VARCHAR(40)	NOT NULL,	
	Duracion DATE NOT NULL,
	TiempoCartelera DATE NOT NULL

	CONSTRAINT FK_Categoria FOREIGN KEY (IdCategoriaPeli) REFERENCES GestionCine.CategoriaPeli,
	CONSTRAINT CHK_IdPelicula CHECK (IdCategoriaPeli LIKE 'CAT[0-9][0-9][0-9]')
)
GO

IF OBJECT_ID('GestionCine.Cine','U') IS NOT NULL
BEGIN
	DROP TABLE GestionCine.Cine
END
GO

CREATE TABLE GestionCine.Cine
(
	IdCine	CHAR(6)	PRIMARY KEY,
	IdPelicula	Char(6) NOT NULL,
	Nombre	VARCHAR(40)	NOT NULL,	
	Telefono CHAR(9) NOT NULL,
	Horario VARCHAR(20) NOT NULL,
	Ubicacion	VARCHAR(40)	NOT NULL

	CONSTRAINT FK_Pelicula FOREIGN KEY (IdPelicula) REFERENCES GestionCine.Pelicula(IdPelicula),
	CONSTRAINT CHK_IdCine CHECK (IdCine LIKE 'CIN[0-9][0-9][0-9]')
)
GO

IF OBJECT_ID('GestionCine.Sala','U') IS NOT NULL
BEGIN
	DROP TABLE GestionCine.Sala
END
GO

CREATE TABLE GestionCine.Sala
(
	IdSala	CHAR(6)	PRIMARY KEY,
	IdCine	CHAR(6)	,
	Nombre	VARCHAR(40)	NOT NULL,	
	Capacidad INT,
	IdTipo	INT,
	Piso	INT

	CONSTRAINT FK_TipoSala FOREIGN KEY (IdTipo) REFERENCES GestionCine.Tipo(IdTipo),
	CONSTRAINT FK_SalaCine FOREIGN KEY (IdCine) REFERENCES GestionCine.Cine(IdCine),

	CONSTRAINT CHK_IdSala CHECK (IdSala LIKE 'SAL[0-9][0-9][0-9]')
)
GO

IF OBJECT_ID('GestionCine.Asiento','U') IS NOT NULL
BEGIN
	DROP TABLE GestionCine.Asiento
END
GO

CREATE TABLE GestionCine.Asiento
(
	IdAsiento CHAR(3) PRIMARY KEY,
	IdSala	CHAR  (6),
	Disponible	BIT 

	CONSTRAINT FK_AsientoSala FOREIGN KEY (IdSala) REFERENCES GestionCine.Sala(IdSala),

	CONSTRAINT CHK_IdAsiento CHECK (IdAsiento LIKE 'ASI[0-9][0-9][0-9]')
)
GO

IF OBJECT_ID('GestionCine.Ticket','U') IS NOT NULL
BEGIN
	DROP TABLE GestionCine.Ticket
END
GO

CREATE TABLE GestionCine.Ticket
(
	IdTicket	CHAR(6) PRIMARY KEY,
	IdCuenta	CHAR(6) NOT NULL,
	IdCine		CHAR(6) NOT NULL,
	IdSala		CHAR(6) NOT NULL,
	IdBebida	CHAR(3) NULL,
	IdDulceria	CHAR(3) NULL,
	Piso		INT,

	CONSTRAINT FK_TicketCuenta FOREIGN KEY (IdCuenta) REFERENCES Usuario.Cuenta(IdCuenta),
	CONSTRAINT FK_TicketCine FOREIGN KEY (IdCine) REFERENCES GestionCine.Cine(IdCine),
	CONSTRAINT FK_TicketSala FOREIGN KEY (IdSala) REFERENCES GestionCine.Sala(IdSala)	
)
GO

--Consesiones
IF OBJECT_ID('Consesiones.Bebida','U') IS NOT NULL
BEGIN
	DROP TABLE GestionCine.Bebida
END
GO

CREATE TABLE GestionCine.Bebida
(
	IdBebida	CHAR(3) PRIMARY KEY,
	Descripcion VARCHAR(30),

	CONSTRAINT CHK_IdBebida CHECK (IdBebida LIKE 'B[0-9][0-9]')
)
GO

IF OBJECT_ID('Consesiones.Dulceria','U') IS NOT NULL
BEGIN
	DROP TABLE GestionCine.Dulceria
END
GO

CREATE TABLE GestionCine.Dulceria
(
	IdDulceri	CHAR(3) PRIMARY KEY,
	Descripcion VARCHAR(30),

	CONSTRAINT CHK_IdDulceri CHECK (IdDulceri LIKE 'D[0-9][0-9]')
)
GO