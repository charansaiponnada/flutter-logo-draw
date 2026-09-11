# flutter_logo_draw



A reusable Flutter widget that **traces a logo outline like a pen and then reveals its fill**. It is the Flutter counterpart to [swiftui-logo-draw](https://github.com/RhuanCruz/swiftui-logo-draw).



## Install



Until published, point your app at GitHub:



```yaml

dependencies:

  flutter_logo_draw:

    git:

      url: https://github.com/charansaiponnada/flutter-logo-draw.git

```



## Usage



```dart

import 'package:flutter_logo_draw/flutter_logo_draw.dart';



LogoDraw(

  logo: runnerLogoPath,

  size: 160,

  drawDuration: const Duration(milliseconds: 1200),

  fillStartPercent: 70,

  fillDuration: const Duration(milliseconds: 350),

  outlineColor: Colors.black,

  fillColor: Colors.black,

  onComplete: () => Navigator.pushReplacementNamed(context, '/home'),

)

```



The widget accepts a Flutter `Path`. Keep the path clean, non-self-intersecting, and add subpaths in the order you want them traced. Because Flutter can compute `PathMetric` directly, no separate `pathLength` parameter is required.



## API



| Parameter | Default | Description |

|---|---:|---|

| `drawDuration` | `1200 ms` | Outline duration. |

| `fillStartPercent` | `70` | Point in the outline animation where fill begins. |

| `fillDuration` | `350 ms` | Fill fade duration. |

| `fillsLogo` | `true` | Set false for outline-only animation. |

| `replayTrigger` | `0` | Change this value to replay. |

| `freezeAt` | — | Fixed progress from `0` to `1`, useful for screenshots. |

| `onComplete` | — | Called after the fill finishes. |



## Converting a logo



Start with a high-resolution monochrome SVG or PNG. Convert the artwork to Flutter `Path` commands, normalize coordinates to a square viewBox, and preserve subpath order. Avoid noisy bitmap traces; a small number of intentional curves produces a cleaner pen effect.



## Accessibility



The widget exposes a semantic image label and honors Flutter's `MediaQuery.disableAnimations` setting by displaying the completed logo immediately.



MIT License. Inspired by the animation model in the original SwiftUI project; this implementation is independent and written for Flutter.

