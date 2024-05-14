use master
go

IF DB_ID('CineClub') IS NOT NULL
BEGIN
	DROP DATABASE CineClub
END
GO

CREATE DATABASE CineClub
GO

use CineClub
go