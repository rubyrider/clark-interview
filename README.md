## Reward Calculator Project

### Problems

Inputs:
```txt
2018-06-12 09:41 A recommends B
2018-06-14 09:41 B accepts
2018-06-16 09:41 B recommends C
2018-06-17 09:41 C accepts
2018-06-19 09:41 C recommends D
2018-06-23 09:41 B recommends D
2018-06-25 09:41 D accepts
```

Outputs:
```ruby
{ “A”: 1.75, “B”: 1.5, “C”: 1 }
```

## Interactive Console

How to test, right? Just type the following and hit enter:

```bash
bin/console
```

Enter the followings example:
```ruby
   file = File.new('./sample.txt')
   reward_builder = RewardCalculator.new(file)
   reward_builder.call
   # => {"A"=>1.75, "B"=>1.5, "C"=>1}
```

## About the System Design Concept: A Top Level Story

The whole calculator is built with 3 main plain old ruby service objects and they are as following"

```ruby
InputFileHandler
Invitation
Parser
RewardCalculator # The main entry point
```

1. The reward calculator takes the file input and pass it on to `InputFileHandler`

2. The `InputFileHandler` receives the file and validate and start parsing news 
lines and yield each line to the `RewardCalculator` service object.

3. The `RewardCalculator` then pass the lines getting from the yieldings of `InputFileHandler` to
the `Parser` service object. The `Parser` return the tokens. `Strscan` is used 
to efficiently build the tokens by scanning the input text.

4. The tokens from the `Parser` is being passed to `Invitation` builder service object and built.

5. `RewardCalculator` will than check for everything with validators and do the calculator.


For the details code documentation run the yard server with the following command:

```ruby
yard server
```

and hit the `http://0.0.0.0:8808` on your favorite browser/
