import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

const _networkLottieUrl =
    'https://raw.githubusercontent.com/xvrh/lottie-flutter/master/example/assets/lottiefiles/slack_app_loader.json';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Lottie Practice',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: const LottieLabPage(),
    );
  }
}

class LottieLabPage extends StatefulWidget {
  const LottieLabPage({super.key});

  @override
  State<LottieLabPage> createState() => _LottieLabPageState();
}

class _LottieLabPageState extends State<LottieLabPage>
    with TickerProviderStateMixin {
  late final AnimationController _controller;

  Duration? _baseDuration;
  double _speed = 1.0;
  bool _loop = true;
  bool _reverse = false;

  bool _useDynamicDelegate = true;
  bool _useRenderCache = false;
  bool _useMaxFrameRate = false;
  double _delegateOpacity = 1.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onControlledLottieLoaded(LottieComposition composition) {
    _baseDuration ??= composition.duration;
    _applySpeed();

    if (!_controller.isAnimating && _controller.value == 0) {
      _play();
    }
  }

  void _applySpeed() {
    if (_baseDuration == null) {
      return;
    }

    final newDuration = Duration(
      milliseconds: (_baseDuration!.inMilliseconds / _speed).round().clamp(
        1,
        600000,
      ),
    );

    _controller.duration = newDuration;
  }

  void _play() {
    if (_controller.duration == null) {
      return;
    }

    if (_loop) {
      _controller.repeat(reverse: _reverse);
      return;
    }

    if (_reverse) {
      final from = _controller.value == 0 ? 1.0 : _controller.value;
      _controller.reverse(from: from);
    } else {
      _controller.forward(from: _controller.value);
    }
  }

  void _pause() {
    _controller.stop();
  }

  void _restart() {
    if (_controller.duration == null) {
      return;
    }

    _controller.reset();
    _play();
  }

  @override
  Widget build(BuildContext context) {
    final isControllerReady = _controller.duration != null;

    return Scaffold(
      appBar: AppBar(title: const Text('Lottie 실습 확장 예제')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionCard(
            title: '1) Network Lottie',
            subtitle: '원격 JSON 로드 + 로딩/에러 처리',
            child: Lottie.network(
              _networkLottieUrl,
              width: 180,
              repeat: true,
              frameBuilder: (context, child, composition) {
                if (composition == null) {
                  return const SizedBox(
                    width: 180,
                    height: 180,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                return child;
              },
              errorBuilder: (context, error, stackTrace) {
                return const SizedBox(
                  width: 180,
                  height: 180,
                  child: Center(child: Text('네트워크 로드 실패')),
                );
              },
            ),
          ),
          _SectionCard(
            title: '2) Asset Lottie',
            subtitle: '프로젝트에 포함된 JSON 에셋 로드',
            child: Lottie.asset(
              'assets/lottie/walking.json',
              width: 220,
              fit: BoxFit.contain,
              repeat: true,
            ),
          ),
          _SectionCard(
            title: '3) Controller Lottie',
            subtitle: '재생/정지/재시작 + 진행도 슬라이더 + 속도 제어',
            child: Column(
              children: [
                Lottie.asset(
                  'assets/lottie/walking.json',
                  width: 220,
                  controller: _controller,
                  onLoaded: _onControlledLottieLoaded,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    FilledButton(
                      onPressed: isControllerReady ? _play : null,
                      child: const Text('Play'),
                    ),
                    FilledButton.tonal(
                      onPressed: isControllerReady ? _pause : null,
                      child: const Text('Pause'),
                    ),
                    OutlinedButton(
                      onPressed: isControllerReady ? _restart : null,
                      child: const Text('Restart'),
                    ),
                  ],
                ),
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    final progress = _controller.value.clamp(0.0, 1.0);
                    return Column(
                      children: [
                        Slider(
                          value: progress,
                          onChanged: isControllerReady
                              ? (value) {
                                  _controller.value = value;
                                }
                              : null,
                        ),
                        Text(
                          'Progress: ${(progress * 100).toStringAsFixed(0)}%',
                        ),
                      ],
                    );
                  },
                ),
                Row(
                  children: [
                    const SizedBox(width: 12),
                    const Text('Speed'),
                    Expanded(
                      child: Slider(
                        min: 0.25,
                        max: 2.0,
                        divisions: 7,
                        value: _speed,
                        label: '${_speed.toStringAsFixed(2)}x',
                        onChanged: (value) {
                          setState(() {
                            _speed = value;
                          });
                          _applySpeed();
                        },
                      ),
                    ),
                    Text('${_speed.toStringAsFixed(2)}x'),
                    const SizedBox(width: 12),
                  ],
                ),
              ],
            ),
          ),
          _SectionCard(
            title: '4) Lottie 추가 기능',
            subtitle: 'repeat/reverse + frameRate + renderCache + delegates',
            child: Column(
              children: [
                Lottie.asset(
                  'assets/lottie/shapes.json',
                  width: 220,
                  repeat: _loop,
                  reverse: _reverse,
                  frameRate: _useMaxFrameRate
                      ? FrameRate.max
                      : FrameRate.composition,
                  renderCache: _useRenderCache
                      ? RenderCache.drawingCommands
                      : null,
                  delegates: _useDynamicDelegate
                      ? LottieDelegates(
                          values: [
                            ValueDelegate.color(const [
                              '**',
                              'Fill 1',
                            ], value: Colors.red),
                            ValueDelegate.opacity(const [
                              '**',
                              'Fill 1',
                            ], value: (_delegateOpacity * 100).round()),
                            ValueDelegate.opacity(const [
                              '**',
                              'Stroke 1',
                            ], value: (_delegateOpacity * 100).round()),
                          ],
                        )
                      : null,
                ),
                if (_useDynamicDelegate) ...[
                  const SizedBox(height: 8),
                  const Text('Delegate Opacity'),
                  Slider(
                    min: 0.0,
                    max: 1.0,
                    divisions: 10,
                    label: '${(_delegateOpacity * 100).round()}%',
                    value: _delegateOpacity,
                    onChanged: (value) {
                      setState(() {
                        _delegateOpacity = value;
                      });
                    },
                  ),
                ],
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilterChip(
                      label: const Text('Loop'),
                      selected: _loop,
                      onSelected: (value) {
                        setState(() {
                          _loop = value;
                        });
                      },
                    ),
                    FilterChip(
                      label: const Text('Reverse'),
                      selected: _reverse,
                      onSelected: (value) {
                        setState(() {
                          _reverse = value;
                        });
                      },
                    ),
                    FilterChip(
                      label: const Text('FrameRate.max'),
                      selected: _useMaxFrameRate,
                      onSelected: (value) {
                        setState(() {
                          _useMaxFrameRate = value;
                        });
                      },
                    ),
                    FilterChip(
                      label: const Text('RenderCache'),
                      selected: _useRenderCache,
                      onSelected: (value) {
                        setState(() {
                          _useRenderCache = value;
                        });
                      },
                    ),
                    FilterChip(
                      label: const Text('Dynamic Delegate'),
                      selected: _useDynamicDelegate,
                      onSelected: (value) {
                        setState(() {
                          _useDynamicDelegate = value;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 10),
            Center(child: child),
          ],
        ),
      ),
    );
  }
}
