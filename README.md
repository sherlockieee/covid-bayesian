#COVID Bayesian Network with Prolog

Code taken from  https://github.com/yunitarp/ReasoningTrainDisruptionWithProlog, with modification. Thanks god for these people.


## Usage
To run Prolog in the command line:

If you haven't installed SWI-Prolog, 
YOU ARE A DISAPPOINTMENT.

Jk, you can install it using this in the terminal:
`$ brew install swi-prolog`

Now you can:
1. Clone this repository to your local folder.
2. Go to the directory where the Prolog files are. 
```
$ cd PrologCOVID/PrologProgram
```
3. Run Prolog.
```
$ swipl user_interface.pl
```
You should see the "Welcome to SWI-Prolog" and the weird "?-" in your terminal now. 
4. We also charge consultation fees:
```
$ consult('rules.pl').
$ consult('bayesian_network.pl').
```
Remember the dots!!!
5. Run `menu.` in your terminal after consultation.
6. Enjoy :)) 