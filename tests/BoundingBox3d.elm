{- This Source Code Form is subject to the terms of the Mozilla Public License,
   v. 2.0. If a copy of the MPL was not distributed with this file, you can
   obtain one at http://mozilla.org/MPL/2.0/.

   Copyright 2016 by Ian Mackenzie
   ian.e.mackenzie@gmail.com
-}


module BoundingBox3d exposing (suite)

import Json.Decode as Decode
import Test exposing (Test)
import Expect
import Test.Runner.Html as Html
import OpenSolid.BoundingBox3d as BoundingBox3d
import OpenSolid.Core.Encode as Encode
import OpenSolid.Core.Decode as Decode
import OpenSolid.Core.Fuzz as Fuzz
import OpenSolid.Core.Expect as Expect


jsonRoundTrips : Test
jsonRoundTrips =
    Test.fuzz Fuzz.boundingBox3d
        "JSON conversion round-trips properly"
        (\value ->
            let
                encoded =
                    Encode.boundingBox3d value

                decoded =
                    Decode.decodeValue Decode.boundingBox3d encoded
            in
                case decoded of
                    Ok result ->
                        if BoundingBox3d.isEmpty value then
                            Expect.true "Expected empty bounding box to round-trip to empty bounding box"
                                (BoundingBox3d.isEmpty result)
                        else
                            Expect.equal result value

                    Err string ->
                        Expect.fail string
        )


fromPointsConsistentWithContaining : Test
fromPointsConsistentWithContaining =
    Test.fuzz2 Fuzz.point3d
        Fuzz.point3d
        "'containing' is consistent with 'fromPoints'"
        (\first second ->
            BoundingBox3d.containing [ first, second ]
                |> Expect.boundingBox3d (BoundingBox3d.fromPoints first second)
        )


suite : Test
suite =
    Test.describe "OpenSolid.Core.BoundingBox3d"
        [ jsonRoundTrips
        , fromPointsConsistentWithContaining
        ]


main : Program Never
main =
    Html.run suite
