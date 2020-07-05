# PiSays

Simon Says game implementation with Raspberry Pi and Nerves.

!()[https://media.giphy.com/media/Zabia7dy8zdtBwnru5/giphy.gif]


## Hardware requirements
- 4 buttons
- Raspberry Pi (I used a zero W but any other else would work)
- Experimental bread board
- Cables
- Piezoelectric buzzer (or a different color led)
- 4 different leds, blue, red, yellow and green
- 4 220 ohm resistors (the less, the brighter)
  
## Hardware configuration:

The gpio pin configuration is set within the `GPIOConfig` file, it can be modified as desire but apparently the input interrupts necessary for the buttons are not supported on some pins, the following configuration worked with a Raspberry Pi Zero:

```
@colors_gpios [red: 3, green: 5, blue: 9, yellow: 10]
@buttons_gpios [red: 4, green: 6, blue: 8, yellow: 7]
@buzzer_gpio 11
```

Each led requires an electric resistor in series, this is my config:

!()[raspberry_pi_config.png]



## Targets

Nerves applications produce images for hardware targets based on the
`MIX_TARGET` environment variable. If `MIX_TARGET` is unset, `mix` builds an
image that runs on the host (e.g., your laptop). This is useful for executing
logic tests, running utilities, and debugging. Other targets are represented by
a short name like `rpi3` that maps to a Nerves system image for that platform.
All of this logic is in the generated `mix.exs` and may be customized. For more
information about targets see:

https://hexdocs.pm/nerves/targets.html#content

## Getting Started

To start your Nerves app:
  * `export MIX_TARGET=my_target` or prefix every command with
    `MIX_TARGET=my_target`. For example, `MIX_TARGET=rpi3`
  * Install dependencies with `mix deps.get`
  * Create firmware with `mix firmware`
  * Burn to an SD card with `mix firmware.burn`

## Learn more

  * Official docs: https://hexdocs.pm/nerves/getting-started.html
  * Official website: https://nerves-project.org/
  * Forum: https://elixirforum.com/c/nerves-forum
  * Discussion Slack elixir-lang #nerves ([Invite](https://elixir-slackin.herokuapp.com/))
  * Source: https://github.com/nerves-project/nerves
