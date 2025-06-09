Subasta Smart Contract

Este contrato inteligente implementa una subasta donde los participantes pueden hacer ofertas mayores al 5% de la mejor oferta actual.

Funcionalidades

- Constructor para definir duración de la subasta.
- Función para ofertar con depósito.
- Mostrar ganador y ofertas.
- Reembolsos a participantes no ganadores.
- Extensión del tiempo si la oferta es en últimos 10 minutos.
- Comisión del 2% al finalizar.
- Eventos para seguimiento de la subasta.

 Variables importantes

- `ganador`: dirección del mejor oferente.
- `mejorOferta`: monto de la mejor oferta.
- `finSubasta`: timestamp cuando finaliza la subasta.

Eventos

- `NuevaOferta`: cuando alguien hace una oferta.
- `SubastaFinalizada`: al terminar la subasta.
- `Reembolso`: cuando un participante recibe devolución.

Cómo desplegar

1. Compilar con Solidity 0.8.20.
2. Desplegar en la red Sepolia.
3. Pasar duración en minutos al constructor.

Link al contrato verificado

https://sepolia.etherscan.io/address/0x17df32fE025D4Ac373699B9a082E2C00aEdb4aaf#code

