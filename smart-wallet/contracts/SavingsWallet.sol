// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract SavingsWallet {
    struct Goal {
        string name;
        uint256 balance;
        address tokenAddress; // Token or stablecoin address
        bool exists;
    }

    mapping(address => mapping(string => Goal)) private userGoals;

    // Custom Errors
    error SavingsWallet__GoalAlreadyExists();
    error SavingsWallet__GoalDoesNotExist();
    error SavingsWallet__InsufficientBalance();
    error SavingsWallet__TokenTransferFailed();

    event GoalCreated(
        address indexed user,
        string goalName,
        address tokenAddress
    );
    event TokensSaved(address indexed user, string goalName, uint256 amount);
    event TokensTransferred(
        address indexed user,
        string goalName,
        address to,
        uint256 amount
    );
    event TokensWithdrawn(
        address indexed user,
        string goalName,
        uint256 amount
    );

    // Create a savings goal
    function createGoal(string memory goalName, address tokenAddress) external {
        if (userGoals[msg.sender][goalName].exists) {
            revert SavingsWallet__GoalAlreadyExists();
        }

        userGoals[msg.sender][goalName] = Goal({
            name: goalName,
            balance: 0,
            tokenAddress: tokenAddress,
            exists: true
        });

        emit GoalCreated(msg.sender, goalName, tokenAddress);
    }

    // Save tokens to a specific goal
    function saveTokens(string memory goalName, uint256 amount) external {
        Goal storage goal = userGoals[msg.sender][goalName];
        if (!goal.exists) {
            revert SavingsWallet__GoalDoesNotExist();
        }

        IERC20 token = IERC20(goal.tokenAddress);
        bool success = token.transferFrom(msg.sender, address(this), amount);
        if (!success) {
            revert SavingsWallet__TokenTransferFailed();
        }

        goal.balance += amount;

        emit TokensSaved(msg.sender, goalName, amount);
    }

    // Transfer tokens to another user
    function transferTokens(
        string memory goalName,
        address to,
        uint256 amount
    ) external {
        Goal storage goal = userGoals[msg.sender][goalName];
        if (!goal.exists) {
            revert SavingsWallet__GoalDoesNotExist();
        }
        if (goal.balance < amount) {
            revert SavingsWallet__InsufficientBalance();
        }

        goal.balance -= amount;

        IERC20 token = IERC20(goal.tokenAddress);
        bool success = token.transfer(to, amount);
        if (!success) {
            revert SavingsWallet__TokenTransferFailed();
        }

        emit TokensTransferred(msg.sender, goalName, to, amount);
    }

    // Withdraw tokens from a goal
    function withdrawTokens(string memory goalName, uint256 amount) external {
        Goal storage goal = userGoals[msg.sender][goalName];
        if (!goal.exists) {
            revert SavingsWallet__GoalDoesNotExist();
        }
        if (goal.balance < amount) {
            revert SavingsWallet__InsufficientBalance();
        }

        goal.balance -= amount;

        IERC20 token = IERC20(goal.tokenAddress);
        bool success = token.transfer(msg.sender, amount);
        if (!success) {
            revert SavingsWallet__TokenTransferFailed();
        }

        emit TokensWithdrawn(msg.sender, goalName, amount);
    }

    // View balance of a specific goal
    function viewGoalBalance(
        string memory goalName
    ) external view returns (uint256) {
        Goal storage goal = userGoals[msg.sender][goalName];
        if (!goal.exists) {
            revert SavingsWallet__GoalDoesNotExist();
        }
        return goal.balance;
    }
}
