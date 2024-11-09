local mono = {
  base = '#eeeeee',
  b0 = '#000000',
  b1 = '#111111',
  b2 = '#222222',
  b3 = '#333333',
  b4 = '#444444',
  b5 = '#555555',
  b6 = '#666666',
  b7 = '#777777',
  b8 = '#888888',
  b9 = '#999999',
  b10 = '#aaaaaa',
  b11 = '#bbbbbb',
  b12 = '#cccccc',
  b13 = '#dddddd',
  b14 = '#eeeeee',
  b15 = '#ffffff',
}

local blues = {
  highlight = '#0eeaea',
  lighter = '#7ff4f4',
  light = '#19d1d1',
  base = '#1dafaf',
  dark = '#1a8f8f',
  darker = '#204747',
}

return {
  bg = {
    base = mono.b0,
    active = blues.darker,
  },
  fg = {
    base = mono.b13,
    active = blues.base,
  },
  text = {
    base = mono.base,
    dark = mono.b8,
    light = mono.b15,
    active = blues.light,
    highlight = blues.highlight,
  },
  mono = mono,
  blue = blues,
}
