extern crate pest;
#[macro_use]
extern crate pest_derive;

use pest::Parser;
use std::process::ExitCode;

#[derive(Parser)]
#[grammar = "grammar.pest"]
struct CommitMessageParser;

fn main() -> ExitCode {
    let args: Vec<_> = std::env::args().collect();
    if args.len() > 1 {
        check_commit_message_pattern(&args[1])
    } else {
        ExitCode::FAILURE
    }
}

fn check_commit_message_pattern(msg_temp_file: &str) -> ExitCode {
    let msg = std::fs::read_to_string(msg_temp_file).unwrap();

    let commit_message = CommitMessageParser::parse(Rule::main, &msg).unwrap_or_else(|e| {
        println!("{}", e);
        std::process::exit(1)
    });

    traversal_rules(commit_message)
}

fn traversal_rules(pairs: pest::iterators::Pairs<Rule>) -> ExitCode {
    for pair in pairs {
        match pair.as_rule() {
            Rule::tag | Rule::scope | Rule::body | Rule::footer | Rule::main | Rule::EOI => {}
            Rule::subject => {
                let subject = pair.as_str();

                if subject.chars().count() > 50 {
                    println!("Limit the subject line to 50 characters");
                    return ExitCode::FAILURE;
                }

                if subject
                    .chars()
                    .next()
                    .expect("Subject must not be empty\nThis is a bug")
                    .is_uppercase()
                {
                    println!("Do not capitalize the first letter");
                    return ExitCode::FAILURE;
                }

                if subject.ends_with('.') {
                    println!("No dot at the end of the subject");
                    return ExitCode::FAILURE;
                }
            }
            Rule::title => {
                traversal_rules(pair.clone().into_inner());
            }
            Rule::message => {
                traversal_rules(pair.clone().into_inner());
            }
            _ => {
                println!("{:?}", pair);
                unreachable!()
            }
        };
    }

    ExitCode::SUCCESS
}
