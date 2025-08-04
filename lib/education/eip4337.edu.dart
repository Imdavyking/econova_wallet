import 'package:flutter/material.dart';

class EIP4337Education extends StatelessWidget {
  const EIP4337Education({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Educational Content')),
      body: const EducationStepper(),
    );
  }
}

class EducationStepper extends StatefulWidget {
  const EducationStepper({super.key});

  @override
  State<EducationStepper> createState() => _EducationStepperState();
}

class _EducationStepperState extends State<EducationStepper> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Stepper(
      currentStep: _index,
      onStepCancel: () {
        if (_index > 0) {
          setState(() {
            _index -= 1;
          });
        }
      },
      onStepContinue: () {
        if (_index < 3) {
          // Updated to reflect the new step count
          setState(() {
            _index += 1;
          });
        }
      },
      onStepTapped: (int index) {
        setState(() {
          _index = index;
        });
      },
      steps: <Step>[
        Step(
          stepStyle: const StepStyle(color: Color.fromARGB(255, 47, 47, 47)),
          title: const Text(
            'Introduction to Financial Principles',
            style: TextStyle(
              fontSize: 18,
            ),
          ),
          content: Container(
            alignment: Alignment.centerLeft,
            child: RichText(
              text: TextSpan(
                style: DefaultTextStyle.of(context).style,
                children: const <TextSpan>[
                  TextSpan(
                    text:
                        'Financial principles form the foundation of personal and business finance. Here are key concepts:\n\n',
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                  TextSpan(
                    text: '1. Saving: ',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  TextSpan(
                    style: TextStyle(
                      fontSize: 18,
                    ),
                    text:
                        'Setting aside a portion of your income regularly helps in building a financial cushion. This is important for emergencies and future expenses.\n',
                  ),
                  TextSpan(
                    text: '2. Budgeting: ',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  TextSpan(
                    style: TextStyle(
                      fontSize: 18,
                    ),
                    text:
                        'Creating a budget helps you track your income and expenses, ensuring that you live within your means and avoid unnecessary debt.\n',
                  ),
                  TextSpan(
                    text: '3. Managing Debt: ',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  TextSpan(
                    style: TextStyle(
                      fontSize: 18,
                    ),
                    text:
                        'Understanding the difference between good debt (like a mortgage) and bad debt (like high-interest credit card debt) is crucial. Aim to pay off bad debt quickly and manage good debt responsibly.\n',
                  ),
                  TextSpan(
                    text: '4. Compound Interest: ',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  TextSpan(
                    style: TextStyle(
                      fontSize: 18,
                    ),
                    text:
                        'This is the interest on a loan or deposit calculated based on both the initial principal and the accumulated interest from previous periods. It’s a powerful tool for growing wealth over time.',
                  ),
                ],
              ),
            ),
          ),
        ),
        Step(
          stepStyle: const StepStyle(color: Color.fromARGB(255, 47, 47, 47)),
          title: const Text(
            'Understanding Blockchain Technology',
            style: TextStyle(
              fontSize: 18,
            ),
          ),
          content: Container(
            alignment: Alignment.centerLeft,
            child: RichText(
              text: TextSpan(
                style: DefaultTextStyle.of(context).style,
                children: const <TextSpan>[
                  TextSpan(
                    style: TextStyle(
                      fontSize: 18,
                    ),
                    text:
                        'Blockchain is a revolutionary technology that underpins cryptocurrencies like Bitcoin and Ethereum. Key concepts include:\n\n',
                  ),
                  TextSpan(
                    text: '1. Decentralization: ',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  TextSpan(
                    style: TextStyle(
                      fontSize: 18,
                    ),
                    text:
                        'Unlike traditional financial systems, blockchain operates without a central authority. This means that no single entity, like a bank or government, controls the blockchain.\n',
                  ),
                  TextSpan(
                    text: '2. Consensus Mechanisms: ',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  TextSpan(
                    style: TextStyle(
                      fontSize: 18,
                    ),
                    text:
                        'These are protocols that help all participants in the blockchain network agree on the validity of transactions. Examples include Proof of Work (PoW) and Proof of Stake (PoS).\n',
                  ),
                  TextSpan(
                    text: '3. Smart Contracts: ',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  TextSpan(
                    style: TextStyle(
                      fontSize: 18,
                    ),
                    text:
                        'These are self-executing contracts with the terms of the agreement directly written into code. They automatically execute actions when predefined conditions are met, removing the need for intermediaries.\n',
                  ),
                  TextSpan(
                    text: '4. Immutable Ledger: ',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  TextSpan(
                    style: TextStyle(
                      fontSize: 18,
                    ),
                    text:
                        'Once data is recorded on the blockchain, it cannot be altered. This ensures transparency and trust, as all transactions are permanently logged and accessible to all network participants.',
                  ),
                ],
              ),
            ),
          ),
        ),
        Step(
          stepStyle: const StepStyle(color: Color.fromARGB(255, 47, 47, 47)),
          title: const Text(
            'Investment Strategies',
            style: TextStyle(
              fontSize: 18,
            ),
          ),
          content: Container(
            alignment: Alignment.centerLeft,
            child: RichText(
              text: TextSpan(
                style: DefaultTextStyle.of(context).style,
                children: const <TextSpan>[
                  TextSpan(
                    style: TextStyle(
                      fontSize: 18,
                    ),
                    text:
                        'Investing is about growing your wealth over time. Here are some strategies to consider:\n\n',
                  ),
                  TextSpan(
                    text: '1. Risk Management: ',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  TextSpan(
                    style: TextStyle(
                      fontSize: 18,
                    ),
                    text:
                        'Understand your risk tolerance before investing. Higher returns usually come with higher risks, so it’s important to balance your investments according to your comfort level.\n',
                  ),
                  TextSpan(
                    text: '2. Diversification: ',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  TextSpan(
                    style: TextStyle(
                      fontSize: 18,
                    ),
                    text:
                        'Don’t put all your eggs in one basket. Spread your investments across different asset classes (stocks, bonds, real estate, cryptocurrencies) to reduce risk.\n',
                  ),
                  TextSpan(
                    text: '3. Long-Term vs. Short-Term Investing: ',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  TextSpan(
                    style: TextStyle(
                      fontSize: 18,
                    ),
                    text:
                        'Long-term investing often involves buying assets with the intention of holding them for several years, benefiting from compound growth. Short-term investing, on the other hand, focuses on quick profits and often involves more risk.\n',
                  ),
                  TextSpan(
                    text: '4. Dollar-Cost Averaging: ',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  TextSpan(
                    style: TextStyle(
                      fontSize: 18,
                    ),
                    text:
                        'This strategy involves regularly investing a fixed amount of money, regardless of the market’s condition. It helps reduce the impact of market volatility on your investments.\n',
                  ),
                  TextSpan(
                    text: '5. Rebalancing: ',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  TextSpan(
                    style: TextStyle(
                      fontSize: 18,
                    ),
                    text:
                        'Periodically review and adjust your portfolio to maintain your desired asset allocation, ensuring that you’re not overexposed to any single asset class.',
                  ),
                ],
              ),
            ),
          ),
        ),
        Step(
          stepStyle: const StepStyle(color: Color.fromARGB(255, 47, 47, 47)),
          title: const Text('EIP-4337: Account Abstraction for Smart Wallets'),
          content: Container(
            alignment: Alignment.centerLeft,
            child: RichText(
              text: TextSpan(
                style: DefaultTextStyle.of(context).style,
                children: const <TextSpan>[
                  TextSpan(
                    style: TextStyle(
                      fontSize: 18,
                    ),
                    text:
                        'EIP-4337 is a proposed Ethereum Improvement Proposal that introduces account abstraction, which allows for more flexible and powerful smart wallets. Here’s what it entails:\n\n',
                  ),
                  TextSpan(
                    text: '1. Account Abstraction: ',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  TextSpan(
                    style: TextStyle(
                      fontSize: 18,
                    ),
                    text:
                        'Traditionally, Ethereum accounts are either externally owned (controlled by a private key) or contract-based (controlled by code). EIP-4337 abstracts these differences, enabling more advanced functionalities in smart wallets.\n',
                  ),
                  TextSpan(
                    text: '2. Benefits for Users: ',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  TextSpan(
                    style: TextStyle(
                      fontSize: 18,
                    ),
                    text:
                        'With EIP-4337, users can enjoy features like multi-signature wallets, social recovery (in case you lose your private key), and more intuitive user experiences without compromising security.\n',
                  ),
                  TextSpan(
                    text: '3. Advanced Use Cases: ',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  TextSpan(
                    style: TextStyle(
                      fontSize: 18,
                    ),
                    text:
                        'EIP-4337 enables new possibilities such as gasless transactions (where transaction fees are paid by a third party), batched transactions (executing multiple operations in one transaction), and customizable security models.\n',
                  ),
                  TextSpan(
                    text: '4. Implementation: ',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  TextSpan(
                    style: TextStyle(
                      fontSize: 18,
                    ),
                    text:
                        'EIP-4337 is designed to be implemented at the application layer, meaning it does not require changes to Ethereum’s core protocol, making it easier to adopt without hard forks or network upgrades.',
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
