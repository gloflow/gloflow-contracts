


---

### VYPER install
```console
foo@bar:~$ pip install vyper  
```

---

### BROWNIE (PY) install

```console
foo@bar:~$ python3 -m pip install --user pipx  
foo@bar:~$ python3 -m pipx ensurepath    
```

if python virtual env code is not available:  
```console
foo@bar:~$ sudo apt-get install -y python3.8-venv 
foo@bar:~$ sudo apt-get install python3-tk        # for brownie gui  
foo@bar:~$ pipx install eth-brownie  
```
---

### Ganache

install for dev:
```console
foo@bar:~$ sudo npm install ganache-cli@latest --global
```


start up a local ganache chain:
```console
foo@bar:~$ ganache-cli
```

---

### Open Zeppelin install
```console
foo@bar:~$ brownie pm install OpenZeppelin/openzeppelin-contracts@4.3.2
foo@bar:~$ brownie pm install OpenZeppelin/openzeppelin-contracts@4.4.1
```
---
### Brownie dev

```console
foo@bar:~$ brownie console
foo@bar:~$ brownie compile
foo@bar:~$ brownie test
foo@bar:~$ brownie test --coverage
```

<br>
<br>

`-s`         -  pytest option - run tests in verbose mode  
`--gas`      - run the gas profiler to give consumption numbers of each method  
`--coverage` - check unit test coverage  
```console
foo@bar:~$ brownie test -s --gas --coverage
```


export infura `project_id` and `etherscan_token` to use by the mainnet forking command:
```console
foo@bar:~$ export WEB3_INFURA_PROJECT_ID=project_id
foo@bar:~$ export ETHERSCAN_TOKEN=api_token
```

<br>
<br>

start a local mainnet-fork 
```console
foo@bar:~$ brownie console --network mainnet-fork
```

run tests that use the mainnet-fork contracts
"-s" - verbose mode
```console
foo@bar:~$ brownie test --network mainnet-fork -s tests/test_mainnet_fork.py
```
---
### Brownie contracts deployment
run nft.py deployment script in ./scripts
```console
foo@bar:~$ brownie run nft
```

<br>
<br>

Brownie Py console local deploy (for usage in tests):
> GFnft.deploy({'from': accounts[0]})  
> GFnft[0].tester()  