The Fiscal Printers issue in Brazil
===

Brazilian fiscal law determines that a wide range of retailers must use fiscal printers (in portuguese Emissor de Cupom Fiscal, something like fiscal invoice printer).

Such printers are not simple, not at all. They are complex machines designed to avoid tax evasion filled of rules and checkpoints.

Redução Z
===

One of these checkpoints are called "Redução Z", it is intended to make a fiscal closure for a given day.

It is very important for a retail software to gather all the information of a Redução Z so it can have total control of all taxes that must be paid.

The problem
===

Fiscal Printers are not reliable from the software developers point of view and it'l access libraries (DLLs) do not have all the functions to provide easy access to all fiscal information that the printer holds.

One example is the past "Redução Zs", there are simply no function to retrieve the Redução Z from an arbitrary day. Software have only the chance to ge info from the last Redução Z.

Let's say for some reason other software got the Redução Z from the printer, or for some kind of bug your software was not able to get it, then you will not be able to get it at all, at least not programatically.

Espelho MFD (or Fiscal Memory Mirror)
===

Fortunately these printers provide a way to get a text file of everything it printed, and Redução Zs are printed.

The goal of this project is to get that text, parse it and provide structured information about the Redução Z.
