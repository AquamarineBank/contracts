pragma solidity 0.8.13;

interface IAqua {
    function totalSupply() external view returns (uint);
    function balanceOf(address) external view returns (uint);
    function approve(address spender, uint value) external returns (bool);
    function transfer(address, uint) external returns (bool);
    function transferFrom(address,address,uint) external returns (bool);
    function mint(address, uint) external returns (bool);
    function burn(address, uint) external returns (bool);
    function pauseMinting() external;
    function resumeMinting() external;
}
