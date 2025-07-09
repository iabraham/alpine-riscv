stty raw -echo; 
spike --isa=RV32IMAFDC ../pk gold; 
stty sane
