# Wavesim2D - Vector Wave Simulator

Wavesim2D is a web application that simulates waves travelling through
a vector field medium. Each point in the medium is a vector meaning it
has a magnitude and a direction. This is in contrast to scalar wave
simulators where the points making up the medium only have a magnitude
(amplitude).

_I built this as a toy project to test out WebGPU and my [Live
Cells](https://livecell.gutev.dev) library._

## Wave medium

The medium, which isn't based on any particular physical model, is
made up of a square grid of granules that are evenly spaced out when
the medium is in equilibrium. Each granule can move in both the *x*
and *y* axes. When a granule is displaced from its equilibrium
position it will push the granules closest to it and pull the granules
furthest away from it.

For example if a granule is displaced to the right by 1 it will push
the granule on its right. Likewise, it will also pull the granule on
its left, the granule above it and the granule below it.

## Parameters

### Size

This is the number of granules in the grid. You can change the size by
clicking on the *Change* button underneath the size. The default size
is *50* which means a *50 x 50* grid.

### Simulation Speed

You can control the speed at which the simulation runs using the
*Simulation Speed* slider. Moving the slider to the left adds a delay
between each frame. When the slider is in the rightmost position, no
delay is added between the frames.

### Wave Speed

The *Wave Speed* slider controls the medium's wave propagation speed
(*c*). What this actually controls is how much energy is transferred
between the granules at each time step. When this parameter is set to
the maximum value *1* the maximum amount of energy is transferred
between the granules, which means the granules transfer *1/4* of their
energy to each of their neighbours.

## Boundary

This parameter controls how the simulation behaves at the grid
boundary.

There are two options:

<dl>

<dt>Open</dt>

<dd>

The grid boundary "absorbs" the energy in the simulation, thus
simulating an infinite medium.

**Note**: This is only an approximation, there is always some amount
of energy that is reflected back into the grid. This amount is
negligible in most cases however becomes significant if there is a
large amount of energy in the grid.

</dd>

<dt>Closed</dt>

<dd>

The grid boundary reflects all the energy back into the grid
effectively simulating a closed finite medium (e.g. a ripple tank).

</dd>

</dl>

## Graphics

The graphics parameter doesn't affect the behaviour of the simulation
but controls how it is rendered to the screen.

### Vectors

Each point of the medium is rendered as an arrow pointing in the
direction along which the granule is displaced. The length of the
arrow represents the distance from the granule's equilibrium position,
or in other words the magnitude of the vector.

**Note**: For grid sizes larger than *50 x 50*, downsampling is
performed for efficiency, meaning each arrow represents the average of
the vectors in a given square window.

This is the default rendering mode.

### Blocks

The simulation is rendered as a grid of blocks. Each block is rendered
at the position of its corresponding granule.

**Note**: For grid sizes larger than *50 x 50*, downsampling is
performed for efficiency. This means each block is rendered at the
average position of the granules in a square window.

### Density

This mode displays the *medium density* as a colour-coded heatmap. The
colour indicates how many granules are found in a given region with
red indicating a high density of granules and dark blue indicating
that the region is devoid of granules.

### Amplitude X/Y

These modes display the displacement (amplitude) of each granule in
either the *x* or *y* axes. Cyan indicates an amplitude of *+1* while
dark blue indicates an amplitude of *-1*.

**Note**: Displacements with an absolute value larger than 1 are
clamped to ±1.

## Wave Sources

A wave source can be added using the "Add Wave" button in the bottom
left corner. There are multiple types of wave sources that you can
simulate. Every source has the following common parameters:

<dl>

<dt>Frequency</dt>

<dd>

The frequency at which the source oscillates. This is normalised such
that a frequency of 1 Hz results in one full cycle fitting in the grid
at a time.

</dd>

<dt>Phase</dt>

<dd>

All wave source are synchronised with respect to the global simulation
time. This parameter controls the phase shift of a wave source and is
expressed in multiples of Pi, that is a value of 1 indicates a phase
shift of Pi, a value of 0.5 indicates a phase shift of Pi / 2, etc.

</dd>

<dt>Pulse</dt>

<dd>

If this option is checked, the wave source is removed after one time
step.

</dd>

</dl>

You can edit the parameters of a wave source and remove wave sources,
after they have been created.

### Point

This source creates waves that originate from a single point, at a
given location (*x*, *y*), with a given amplitude in the *x* and *y*
axes.

### Line

This source creates a wave that originates from a line with given
start and end points. Like the point source, you can specify the
amplitude in the both the *x* and *y* axes.

### Circle

This creates a circular wave source. The waves are emitted from the
perimeter of a circle with a given centre and radius. Unlike the line
and point sources, the amplitude is a scalar value. If the amplitude
is negative, the amplitude along the perimeter initially points
towards the centre of the circle, otherwise it points away from the
centre.

### Curl

This wave source creates a displacement that "curls" around a given
point. The amplitude is a scalar value. A positive amplitude indicates
a clockwise curl, while a negative amplitude indicates a
counter-clockwise curl.

### Divergence

This source creates a divergence (or convergence) at a given
point. The amplitude is a scalar value. If the amplitude is positive a
divergence away from the point is created, otherwise if negative a
convergence towards the point is created.


<!-- Local Variables: -->
<!-- ispell-dictionary: "en_GB" -->
<!-- End: -->
