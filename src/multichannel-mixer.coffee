{Mixer, Unzipper, Zipper, FMT_F32LE, FMT_S16LE, FMT_U16LE}  = require "lbmrn-pcm-utils"


class MultichannelMixer extends Zipper
  @formats: {FMT_F32LE, FMT_S16LE, FMT_U16LE}

  constructor: (streams = [], {@maxInputs, @channels, @format}) ->
    @maxInputs  = streams.length or 2
    @channels or= 2
    @format   or= FMT_S16LE

    super @channels, @format

    @streams    = []
    @_unzippers = []
    @_mixers    = for i in [0...@channels]
      mixer = new Mixer @maxInputs, @format
      mixer.pipe @inputs[i]
      mixer

    @add streams...

  add: (streams...) ->
    for stream in streams
      unzipper = new Unzipper @channels, @format
      @_unzippers.push unzipper
      @streams.push stream
      index = @streams.length - 1
      stream.pipe unzipper
      unzipper.outputs[i].pipe @_mixers[i].inputs[index] for i in [0...@channels]

    return this

  remove: (streams...) ->
    for stream in streams
      index = @streams.indexOf stream
      throw new Error "stream not found" unless index > -1
      @streams.splice index, 1
      unzipper = @_unzippers.splice index, 1
      stream.unpipe unzipper
      unzipper.outputs[i].unpipe @_mixers[i].inputs[index] for i in [0...@channels]

    return this


module.exports = MultichannelMixer
