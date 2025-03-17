---
date: 2025-01-31 05:30:00+00:00


slug: 2024-01-31-flappy-tburd
title: Checking out Deepseek R1
categories:
    - software
    - games
    - messing around

---

# In which I attempt to re-invent Flappy Bird

*Last updated Jan 31, 2025*

I've been struck with insomnia and feeling ill, so I've decided to mess around with DeepSeek R1 this morning to keep myself distracted. Like almost everyone in technology today, I'm hearing all this talk about DeepSeek R1 being the best of best so I decided to give it a try to "auto code" something non-trivial.

I've been meaning to learn a little bit of game development to see if I could make small 2D games for fun. Unfortunately for me, I do not have the creativity to design games, so I'm going to try and re-implement Flappy Bird. Using Rust. And [Bevy](https://bevyengine.org/). I'm somewhat familiar with Rust but have absolutely no idea how an entity-component-system (ECS) game engine works or what that means for game development.

My goal is to do the least amount of work possible. I will keep prompting the LLM until I get code that compiles or I run out of free tokens. Then keep prompting to fix any logic/collision/points related bugs. To avoid getting into a copyright battle, I've called my game `flappy-turd`. Please look away now if toilet based humour isn't your thing. Other than that, I'm copy pasta-ing from DeepSeek R1 as it tells me to.

## Diving in

I can't use my work laptop for obvious reasons, I'm using my personal computer that's logged in to DeepSeekR1. I've allocated a max of 30' to do this, as I have other chores that need finishing. I start with a lazy prompt, hoping that DeepSeek can intuit what I need and spit out the code.

{{< figure src="/deepseek1.png" title="The prompt to start it all" >}}

325 seconds is a long time in LLM inference land, so I'm wondering how this service is available for free. I've not paid for any tokens, I think? A quick look at the chain-of-thought (CoT) shows a lot of "Wait, No." Which makes this model output read a lot like thoughts from a Genuine Human (TM). Nice try, Mr Tot A Lee Abbott.

After completing its CoT process, the model spat out a bunch of code that I could copy paste. Neatly organised, somewhat like what you'd get from the Claude Sonnet Web UI.  Like with all LLM output, you want to make sure that you're not following instructions to install a crypto coin miner on your computer. This is especially important if you're trying to be clever and using an arcane programming language, or one that you're not very familiar with. I spent some time reading through the code, convinced myself that it wasn't going to set my house on fire and tried to compile.

## Pls compile

If you're not familiar with rust, your usual dev cycle using Cargo (the rust tool that does it all) looks like this.

1. Write some code
2. Run `cargo add` to add dependencies. Or manually edit the `Cargo.toml` file to add your dependencies.
3. Run `cargo check` or `cargo run`
4. Feel stupid for not knowing what borrow checking is
5. Feel glad that the error message is verbose and actively helpful
6. Search for the error message(s) and join legions of annoyed developers
5. Attempt a fix, rinse and repeat 3.

I copy pasted contents of `src/main.rs` to my cleverly named `flappy-turd` repo. I was being extra clever and decided to `cargo add` my dependencies. What this does is automatically add the latest version of the dependency to your code. I ended up with the latest version of the `bevy` and `rand` crates. Crates are fancy names for rust packages. The output from deepseek recommended specific versions that were much older than the latest versions. Which makes sense, since you'd expect the model to have scraped data at a certain point in time.

As you would expect, the latest version of the `bevy` crate contains code that either breaks old code, or deprecates it. I realised my own error and decided to fix the versions of my dependencies to the ones recommended by deepseek. This reduced the errors from 13 to 1.

Still no compiled code yet. I prompted Deepseek with the particular error, but it kept digging itself into a hole asking me to use an API that was no longer available in the `bevy` crate.

I'm running out of time for this experiment so I decide to cheat a little and use my Human Brain to try and fix the compile error.

## Old fashioned search and copy paste

The compile error seems to be focused on this particular collision API that was apparently removed [some time ago](https://github.com/bevyengine/bevy/pull/11500/commits/a41ff9d269abde5ea155de7d20821b154ca3b23b). I tried to nudge DeepSeek to use the replacement API but it looks like I've run out of tokens

{{< figure src="/deepseek2.png" title="No soup for you!" >}}

I've also run out time for today.

## Thoughts

DeepSeek R1 looks promising. Even though I couldn't get `flappy-turd` to ship, I'm still happy that I got some starter code that almost works (I think?). I've no plans to use this for work related stuff, as we will likely have paid subscriptions to other LLMs if needed. The Chain-of-thought stuff looks really clever, I've known that this exists in other "AIs" but I've not looked at them yet.

I could have decomposed my prompt into smaller steps, and maybe that would've given me a finished product quickly? I might try that out.
