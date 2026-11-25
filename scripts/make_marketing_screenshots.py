#!/usr/bin/env python3
"""스토어 스크린샷 합성: 원본 캡처(docs/screenshots/raw) → HTML → 헤드리스 Chrome.

다시 만들 때: 시뮬레이터에서 디버그 빌드를 -ScreenshotSeed 로 실행해 raw/ 를 새로 찍고
(편집 화면은 -ScreenshotEditor, 첫 화면은 -ScreenshotOnboarding 을 함께) 이 스크립트를 실행한다.
출력: docs/screenshots/marketing/ (아이폰 1242×2688) · marketing/ipad/ (2064×2752)
"""
import pathlib
import subprocess
import tempfile

ROOT = pathlib.Path(__file__).resolve().parent.parent
RAW = ROOT / "docs" / "screenshots" / "raw"
OUT = ROOT / "docs" / "screenshots" / "marketing"
CHROME = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"

NIGHT = "#1b2150"   # 아이콘의 밤하늘
GOLD = "#ffcd60"    # 아이콘의 초승달

# (원본, 배치, 헤드라인, 서브카피)
IPHONE = [
    ("01-list.png", "night", "음력 생신,<br>다시 찾아보지 마세요", "음력으로 한 번만 적으면 해마다 날짜를 알아서"),
    ("02-editor.png", "light", "지나도 D+ 없이<br>바로 다음 해로", "매년 돌아오는 날은 다시 남은 날을 세어요"),
    ("03-onboarding.png", "light", "음력도 양력도<br>원하는 달력으로", "설날 추석 음력 생일까지 정확하게"),
    ("04-list-dark.png", "night", "누구의 날인지<br>한눈에", "엄마 아빠 할머니, 관계를 붙여 두세요"),
]
IPAD = [
    ("ipad/01-list.png", "night", "음력 생신, 다시 찾아보지 마세요", "음력으로 한 번만 적으면 해마다 날짜를 알아서"),
    ("ipad/02-editor.png", "light", "지나도 D+ 없이 바로 다음 해로", "매년 돌아오는 날은 다시 남은 날을 세어요"),
    ("ipad/03-onboarding.png", "light", "음력도 양력도 원하는 달력으로", "설날 추석 음력 생일까지 정확하게"),
]

DEVICES = {
    # 캔버스, 글자 크기, 기기 폭, 테두리 둥글기
    "iphone": dict(w=1242, h=2688, head=96, sub=48, top=230, gap=120, dev=900, radius=110, pad=24, inner=88),
    "ipad": dict(w=2064, h=2752, head=110, sub=56, top=220, gap=120, dev=1640, radius=80, pad=30, inner=52),
}

HTML = """<!doctype html><html><head><meta charset="utf-8"><style>
* {{ margin:0; padding:0; box-sizing:border-box; }}
html,body {{ width:{w}px; height:{h}px; overflow:hidden; }}
body {{ background:{bg}; font-family:-apple-system, "Apple SD Gothic Neo", sans-serif; text-align:center; }}
.headline {{ font-size:{head}px; font-weight:800; color:{fg}; letter-spacing:-2px; line-height:1.22;
  margin-top:{top}px; padding:0 70px; }}
.sub {{ font-size:{sub}px; font-weight:500; color:{subfg}; margin-top:44px; letter-spacing:-1px; }}
.wrap {{ display:flex; justify-content:center; margin-top:{gap}px; }}
.device {{ width:{dev}px; background:#111; border-radius:{radius}px; padding:{pad}px; border:3px solid #3a3a44;
  box-shadow:0 60px 140px rgba(0,0,0,.35); }}
.device img {{ width:100%; display:block; border-radius:{inner}px; }}
.moon {{ color:{gold}; }}
</style></head><body>
<div class="headline">{headline}</div><div class="sub">{subtext}</div>
<div class="wrap"><div class="device"><img src="{img}"></div></div>
</body></html>"""


def render(device, shots, out_dir):
    d = DEVICES[device]
    out_dir.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory() as tmp:
        for src, theme, headline, subtext in shots:
            night = theme == "night"
            html = HTML.format(
                **d, bg=f"linear-gradient(180deg, #2a3478, {NIGHT})" if night else "#f6f2e8",
                fg="#ffffff" if night else "#1b2150", subfg="#c3c8ea" if night else "#7b7f99",
                gold=GOLD, headline=headline, subtext=subtext, img=(RAW / src).as_uri())
            page = pathlib.Path(tmp) / "page.html"
            page.write_text(html, encoding="utf-8")
            out = out_dir / pathlib.Path(src).name
            subprocess.run([CHROME, "--headless=new", f"--screenshot={out}",
                            f"--window-size={d['w']},{d['h']}", "--force-device-scale-factor=1",
                            "--hide-scrollbars", "--disable-gpu", page.as_uri()],
                           check=True, capture_output=True)
            print("rendered", out.relative_to(ROOT))


if __name__ == "__main__":
    render("iphone", IPHONE, OUT)
    render("ipad", IPAD, OUT / "ipad")
