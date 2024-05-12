// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Chess {
    enum GameType {
        Single,
        Multiplayer,
        Staking
    }

    enum BotLevel {
        AbidoShaker,
        GandukaGandusa,
        Lamante
    }

    struct Game{
        GameType mode,
        address[2] participants,
        BotLevel bot,
        string turn,
        string moves,
        string white,
        string black,
        uint256 createdAt,
        boolean gameExists
    }

    function createGame() external {}
    function move() external {}
    function _isGameOver() internal {}
    function resign() external {}
    function getGameBoard() external {}
}
