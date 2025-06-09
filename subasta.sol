// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.20;

contract Subasta {
    address public owner;
    address public ganador;
    uint public mejorOferta;
    uint public finSubasta;
    uint public comision = 2; // 2%
    bool public activa;

    struct Oferta {
        uint monto;
        uint[] historial;
    }

    mapping(address => Oferta) public ofertas;
    address[] public participantes;

    event NuevaOferta(address indexed oferente, uint monto);
    event SubastaFinalizada(address ganador, uint monto);
    event Reembolso(address indexed oferente, uint monto);

    modifier soloDuranteSubasta() {
        require(activa, "La subasta ya ha finalizado");
        require(block.timestamp < finSubasta, "La subasta ha terminado");
        _;
    }

    modifier soloOwner() {
        require(msg.sender == owner, "Solo el owner puede hacer esto");
        _;
    }

    constructor(uint _duracionEnMinutos) {
        owner = msg.sender;
        finSubasta = block.timestamp + (_duracionEnMinutos * 10 minutes);
        activa = true;
    }

    function ofertar() external payable soloDuranteSubasta {
        require(msg.value > 0, "La oferta debe ser mayor a cero");
        uint ofertaMinima = mejorOferta + (mejorOferta * 5) / 100;

        require(msg.value > ofertaMinima || mejorOferta == 0, "La oferta debe superar en al menos 5%");

        if (ofertas[msg.sender].monto == 0) {
            participantes.push(msg.sender); // nuevo participante
        }

        // Guardar historial para reembolsos parciales
        ofertas[msg.sender].historial.push(msg.value);

        ofertas[msg.sender].monto += msg.value;
        mejorOferta = ofertas[msg.sender].monto;
        ganador = msg.sender;

        // Si la oferta se hace en los últimos 10 minutos, se extiende 10 minutos
        if (finSubasta - block.timestamp <= 10 minutes) {
            finSubasta += 10 minutes;
        }

        emit NuevaOferta(msg.sender, msg.value);
    }

    function mostrarGanador() external view returns (address, uint) {
        return (ganador, mejorOferta);
    }

    function mostrarOfertas() external view returns (address[] memory, uint[] memory) {
        uint[] memory montos = new uint[](participantes.length);
        for (uint i = 0; i < participantes.length; i++) {
            montos[i] = ofertas[participantes[i]].monto;
        }
        return (participantes, montos);
    }

    function finalizarSubasta() external soloOwner {
        require(activa, "Ya finalizo");
        require(block.timestamp >= finSubasta, "Aun no termina");

        activa = false;

        uint comisionAmount = (mejorOferta * comision) / 100;
        uint envioFundacion = mejorOferta - comisionAmount;

        payable(owner).transfer(comisionAmount);
        payable(ganador).transfer(envioFundacion); // O quedarse el objeto

        emit SubastaFinalizada(ganador, mejorOferta);
    }

    function devolverDepositos() external {
        require(!activa, "La subasta aun sigue");
        require(msg.sender != ganador, "El ganador no recibe reembolso");

        uint monto = ofertas[msg.sender].monto;
        require(monto > 0, "No hay fondos");

        ofertas[msg.sender].monto = 0;
        payable(msg.sender).transfer(monto);

        emit Reembolso(msg.sender, monto);
    }

    function reembolsoParcial() external {
        require(activa, "Solo durante la subasta");

        uint[] storage hist = ofertas[msg.sender].historial;
        require(hist.length > 1, "No hay reembolso disponible");

        uint monto = hist[hist.length - 2];
        hist[hist.length - 2] = 0;

        payable(msg.sender).transfer(monto);
        emit Reembolso(msg.sender, monto);
    }
}
