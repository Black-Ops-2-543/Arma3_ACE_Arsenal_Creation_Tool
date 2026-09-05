/* Resource safeguards are work/memory bounds, never valid cargo-count caps. */
createHashMapFromArray [
    ["maxInputCharacters", 33554432],
    ["maxLiteralCharacters", 4096],
    ["maxGenericCandidates", 1000000],
    ["maxUnavailableSamples", 64],
    ["maxWarningRows", 96]
]
