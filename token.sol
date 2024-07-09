// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.7;

// Interface para operações seguras de matemática
// A library SafeMath foi utilizada para reduzir custos de gas.
// As funções utilizam internal em vez de public, porque não precisam ser visíveis externamente.
// A utilização de SafeMath para operações aritméticas garantem que não haja underflows ou overflows.
library SafeMath {
    // Função para adição segura
    function safeAdd(uint a, uint b) internal pure returns (uint c) {
        c = a + b;
        require(c >= a, unicode"SafeMath: adição falhou"); // Verifica overflow
    }

    // Função para subtração segura
    function safeSub(uint a, uint b) internal pure returns (uint c) {
        require(b <= a, unicode"SafeMath: subtração falhou"); // Garante que não ocorra underflow
        c = a - b;
    }
    
    // Função para multiplicação segura
    function safeMul(uint a, uint b) internal pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b, unicode"SafeMath: multiplicação falhou"); // Garante que não ocorra overflow
    }

    // Função para divisão segura
    function safeDiv(uint a, uint b) internal pure returns (uint c) {
        require(b > 0, unicode"SafeMath: divisão por zero"); // Garante que o divisor não seja zero
        c = a / b;
    }
}

// Interface ERC20 para token
interface ERC20Interface {
    function totalSupply() external view returns (uint);
    function balanceOf(address tokenOwner) external view returns (uint balance);
    function allowance(address tokenOwner, address spender) external view returns (uint remaining);

    function transfer(address to, uint tokens) external returns (bool success);
    function approve(address spender, uint tokens) external returns (bool success);
    function transferFrom(address from, address to, uint tokens) external returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

// Contrato atual do token ERC20
contract DIOToken is ERC20Interface {
    using SafeMath for uint;

    string public symbol = "DIO";
    string public name = "DIO Coin";
    uint8 public decimals = 2;
    uint256 public _totalSupply;

    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;
 
    // Inicialização do contrato
    constructor() {
        _totalSupply = 1000000; // Total inicial de tokens
        balances[msg.sender] = _totalSupply; // O criador do contrato recebe todos os tokens iniciais
    }

    // Retorna o total de tokens em circulação
    function totalSupply() public view override returns (uint) {
        return _totalSupply;
    }

    // Retorna o saldo do proprietário do token
    function balanceOf(address tokenOwner) public view override returns (uint) {
        return balances[tokenOwner];
    }

    // Transfere tokens para um endereço específico
    function transfer(address to, uint tokens) public override returns (bool) {
        require(tokens <= balances[msg.sender], "Saldo insuficiente"); // Verifica se o remetente tem fundos suficientes

        balances[msg.sender] = balances[msg.sender].safeSub(tokens);
        balances[to] = balances[to].safeAdd(tokens);
        emit Transfer(msg.sender, to, tokens);
        return true;
    }

    // Permite que um spender (spender) retire tokens do endereço do dono
    function approve(address spender, uint tokens) public override returns (bool) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }

    // Retorna o número de tokens que um spender ainda pode retirar do owner
    function allowance(address tokenOwner, address spender) public view override returns (uint) {
        return allowed[tokenOwner][spender];
    }

    // Transfere tokens entre diferentes endereços
    function transferFrom(address from, address to, uint tokens) public override returns (bool) {
        require(tokens <= balances[from], unicode"Saldo insuficiente"); // Verifica se o remetente tem fundos suficientes
        require(tokens <= allowed[from][msg.sender], unicode"Permissão insuficiente"); // Verifica se o spender tem permissão suficiente

        balances[from] = balances[from].safeSub(tokens);
        allowed[from][msg.sender] = allowed[from][msg.sender].safeSub(tokens);
        balances[to] = balances[to].safeAdd(tokens);
        emit Transfer(from, to, tokens);
        return true;
    }
} 
