-include .env

deploy:; forge script script/DeploySvgNft.s.sol:DeploySvgNft --rpc-url $(SEPOLIA) --account defaultKey --sender $(ADDR) --broadcast --verify --etherscan-api-key $(KEY)
mint:; forge script script/Interactions.s.sol:Mint --rpc-url $(SEPOLIA) --account defaultKey --sender $(ADDR) --broadcast 
burn:; forge script script/Interactions.s.sol:Burn  --rpc-url $(SEPOLIA) --account defaultKey --sender $(ADDR) --broadcast 
tokenUri:; forge script script/Interactions.s.sol:TokenURI  --rpc-url $(SEPOLIA) --account defaultKey --sender $(ADDR) --broadcast 
