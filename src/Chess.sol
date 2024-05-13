// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC2771Context} from "@openzeppelin/contracts/metatx/ERC2771Context.sol";

error Chess__GameDoesNotExist();
error Chess__NotAParticipant();
error Chess__GameEnded();
error Chess__InvalidMove();

contract Chess is ERC2771Context {
    mapping(bytes32 => Game) private s_idToGames;
    mapping(bytes32 => mapping(uint8 => string[])) public s_moves;

    constructor(address _trustedForwarder) ERC2771Context(_trustedForwarder) {}

    enum GameType {
        Single,
        Multiplayer,
        Staking
    }

    enum GameStatus {
        Open,
        Aborted,
        Draw,
        Resign,
        CheckMate
    }

    enum BotLevel {
        AbidoShaker,
        GandukaGandusa,
        Lamante
    }

    struct Game {
        GameType mode;
        address[2] participants;
        BotLevel bot;
        GameStatus status;
        address winner;
        string turn;
        string board;
        string white;
        string black;
        uint256 createdAt;
        bool gameExists;
    }

    modifier doesGameExist(bytes32 _gameId) {
        if (!s_idToGames[_gameId].gameExists) {
            revert Chess__GameDoesNotExist();
        }
        _;
    }

    modifier isParticipant(bytes32 _gameId) {
        if (
            s_idToGames[_gameId].participants[0] != _msgSender() &&
            s_idToGames[_gameId].participants[1] != _msgSender()
        ) {
            revert Chess__NotAParticipant();
        }
        _;
    }

    modifier isGameOn(bytes32 _gameId) {
        if (s_idToGames[_gameId].status != GameStatus.Open) {
            revert Chess__GameEnded();
        }
        _;
    }

    modifier isTurn(bytes32 _gameId) {
        if (
            keccak256(bytes(s_idToGames[_gameId].turn)) == keccak256(bytes("w"))
        ) {
            address user = abi.decode(
                bytes(s_idToGames[_gameId].white),
                (address)
            );
            if (user != _msgSender()) {
                revert Chess__InvalidMove();
            }
        }
        if (
            keccak256(bytes(s_idToGames[_gameId].turn)) == keccak256(bytes("b"))
        ) {
            address user = abi.decode(
                bytes(s_idToGames[_gameId].black),
                (address)
            );
            if (user != _msgSender()) {
                revert Chess__InvalidMove();
            }
        }
        _;
    }

    function createGame(
        GameType _mode,
        address _participant,
        BotLevel _bot
    ) external returns (bytes32 _gameId) {
        address[2] memory _participants;
        Game memory _game;
        if (_mode == GameType.Single) {
            _participants[0] = _msgSender();
            _game.mode = _mode;
            _game.participants = _participants;
            _game.bot = _bot;
            _game.turn = "w";
            _game
                .board = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1";
            _game.white = string(abi.encodePacked(_msgSender()));
            _game.black = string(abi.encodePacked(_mode));
            _game.createdAt = block.timestamp;
            _game.gameExists = true;
        }
        if (_mode == GameType.Multiplayer) {
            _participants[0] = _msgSender();
            _participants[1] = _participant;
            _game.mode = _mode;
            _game.participants = _participants;
            _game.bot = _bot;
            _game.turn = "w";
            _game
                .board = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1";
            _game.white = string(abi.encodePacked(_msgSender()));
            _game.black = string(abi.encodePacked(_participant));
            _game.createdAt = block.timestamp;
            _game.gameExists = true;
        }
        _gameId = keccak256(abi.encode(_game));
        s_idToGames[_gameId] = _game;
        return _gameId;
    }

    function move(
        bytes32 _gameId,
        string calldata _fen,
        uint8 _halfMove,
        string calldata _move
    )
        external
        doesGameExist(_gameId)
        isParticipant(_gameId)
        isGameOn(_gameId)
        isTurn(_gameId)
    {
        s_idToGames[_gameId].board = _fen;
        s_moves[_gameId][_halfMove].push(_move);
    }

    function endGame(
        bytes32 _gameId,
        GameStatus _status
    ) external doesGameExist(_gameId) isParticipant(_gameId) isGameOn(_gameId) {
        if (_status == GameStatus.Resign) {
            if (s_idToGames[_gameId].participants[0] == _msgSender()) {
                s_idToGames[_gameId].winner = address(
                    s_idToGames[_gameId].participants[1]
                );
            } else {
                s_idToGames[_gameId].winner = address(
                    s_idToGames[_gameId].participants[0]
                );
            }
        }
        if (_status == GameStatus.CheckMate) {
            s_idToGames[_gameId].winner = address(_msgSender());
        }
        s_idToGames[_gameId].status = _status;
    }

    function getGame(
        bytes32 _gameId
    ) external view doesGameExist(_gameId) returns (Game memory _game) {
        _game = s_idToGames[_gameId];
    }

    // function getMoves(
    //     bytes32 _gameId
    // )
    //     external
    //     view
    //     doesGameExist(_gameId)
    //     returns (mapping(uint8 => string[]) memory _moves)
    // {
    //     _moves = s_moves[_gameId];
    // }
}
