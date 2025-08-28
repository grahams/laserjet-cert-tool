# laserjet-cert-tool

This is a tool for obtaining and deploying an ACME certificate to an HP LaserJet Pro MFP M479fdw using [acme.sh](https://github.com/acmesh-official/acme.sh).

There's a good chance this will work on other modern HP printers running the same stack, but I only have one printer to test.

Copy `.env.example` to `.env` and edit it's values before running to correctly setup the tool's environment.

This should probably be a acme.sh deploy target but I haven't gotten that far yet.  
