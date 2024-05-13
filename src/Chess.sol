// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC2771Context} from "@openzeppelin/contracts/metatx/ERC2771Context.sol";

error Chess__GameDoesNotExist();
error Chess__NotAParticipant();
error Chess__GameEnded();

contract Chess is ERC2771Context {

    mapping(bytes32 => Game) private s_idToGames;


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
        CheckMate,
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
        string moves;
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
            s_idToGames[_gameId].partipants[0] != msg.sender &&
            s_idToGames[_gameId].partipants[1] != msg.sender
        ) {
            revert Chess__NotAParticipant();
        }
        _;
    }

    modifier isGameOn(bytes32 _gameId) {
        if(s_idToGames[_gameId].status != GameStatus.Open){
            revert Chess__GameEnded();
        }
        _;
    }

    modifier isTurn(bytes32 _gameId) {
        if(s_idToGames[_gameId].turn == "w"){
            (_user) = abi.decode(bytes(s_idToGames[_gameId].white), )
            if()
        }
        if(s_idToGames[_gameId].turn == "b"){}
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
            _participants[0] = msg.sender;
            _game.mode = _mode;
            _game.participants = _participants;
            _game.bot = _bot;
            _game.turn = "w";
            _game.moves = "";
            _game.white = string(abi.encodePacked(msg.sender));
            _game.black = string(abi.encodePacked(_mode));
            _game.createdAt = block.timestamp;
            _game.gameExists = true;
        }
        if (_mode == GameType.Multiplayer) {
            _participants[0] = msg.sender;
            _participants[1] = _participant;
            _game.mode = _mode;
            _game.participants = _participants;
            _game.bot = _bot;
            _game.turn = "w";
            _game.moves = "";
            _game.white = string(abi.encodePacked(msg.sender));
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
        string calldata _fen
    )
        external
        doesGameExist(_gameId)
        isParticipant(_gameId)
        isGameOn(_gameId)
        isTurn(_gameId)
    {
        if (s_idToGames[_gameId].gameExists) {
            s_idToGames[_gameId].moves = _fen;
        }
    }
    // function _isGameOver() internal {}
    // function resign() external {}
    // function getGame() external {}
}
