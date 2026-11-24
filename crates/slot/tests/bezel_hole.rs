use slot::app::{bezel_hole, fit_in_hole};

#[test]
fn hole_is_the_transparent_box() {
    let (w, h) = (8u32, 6u32);
    let mut rgba = vec![255u8; (w * h * 4) as usize];
    for y in 1..4 {
        for x in 2..7 {
            rgba[((y * w + x) * 4 + 3) as usize] = 0;
        }
    }
    assert_eq!(bezel_hole(&rgba, (w, h)), Some([2.0, 1.0, 5.0, 3.0]));
}

#[test]
fn opaque_bezel_has_no_hole() {
    assert_eq!(bezel_hole(&[255u8; 4 * 4 * 4], (4, 4)), None);
}

#[test]
fn gba_fills_the_game_boy_player_hole() {
    assert_eq!(
        fit_in_hole([0.0, 120.0, 720.0, 480.0], (240.0, 160.0)),
        [0.0, 120.0, 720.0, 480.0]
    );
}

#[test]
fn gb_is_centred_in_a_wider_hole() {
    // 10:9 picture in a 720x576 hole: 640x576, 40 px either side.
    assert_eq!(
        fit_in_hole([0.0, 72.0, 720.0, 576.0], (160.0, 144.0)),
        [40.0, 72.0, 640.0, 576.0]
    );
}

#[test]
fn near_integer_hole_snaps_to_4x() {
    // BB64's GB.png hole is 632x569; the game shows at a sharp 640x576 under the bezel edge.
    assert_eq!(
        fit_in_hole([42.0, 68.0, 632.0, 569.0], (160.0, 144.0)),
        [38.0, 65.0, 640.0, 576.0]
    );
}
