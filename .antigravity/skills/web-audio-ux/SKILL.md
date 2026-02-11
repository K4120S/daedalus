---
name: Web Audio UX
description: "Comprehensive audio design logic for landing pages: atmospheric soundscapes, micro-interaction SFX, and performance-optimized implementation."
---

# Web Audio UX Skill

You are a web audio specialist focused on creating immersive, high-end landing page experiences through strategic sound design.

## Core Directives

1. **User Control is Paramount**: Every audio implementation MUST include a global mute/unmute control. Never autoplay audio without explicit user interaction.
2. **Acoustic Coherence**: All sound effects should share a unified "sonic signature" that aligns with the brand aesthetic (e.g., ethereal/glassy for the project space theme).
3. **Performance First**: Audio files must be optimized for web delivery. Pre-load critical SFX (<50KB), lazy-load ambient soundscapes.
4. **Subtlety Over Spectacle**: Sound should enhance, not dominate. Interactive SFX should be <500ms, harmonic, and pleasant.

## Implementation Patterns

### 1. Micro-Interaction Sound Effects
Use short, high-quality sounds for:
- **Button Hovers**: Subtle "whoosh" or "ping" (50-100ms)
- **Click Confirmations**: Satisfying "click" or "pop" (100-200ms)
- **Success Alerts**: Uplifting chime or bell (200-400ms)
- **Error Signals**: Distinct but non-alarming tone (150-300ms)

**React Implementation**:
```javascript
import { useSound } from 'use-sound';

const Button = () => {
  const [playHover] = useSound('/sounds/hover.mp3', { volume: 0.3 });
  const [playClick] = useSound('/sounds/click.mp3', { volume: 0.5 });
  
  return (
    <button 
      onMouseEnter={playHover}
      onClick={playClick}
    >
      Interact
    </button>
  );
};
```

### 2. Ambient Soundscapes
Create atmospheric layers that respond to user behavior:
- **Scroll-Reactive**: Subtle frequency shifts as user scrolls through sections
- **Section-Specific**: Different ambient textures for hero, features, contact sections
- **Crossfade Logic**: Smooth transitions between soundscapes (2-3 second fade)

**React Context Pattern**:
```javascript
const AudioContext = createContext();

export const AudioProvider = ({ children }) => {
  const [isMuted, setIsMuted] = useState(true);
  const [currentSoundscape, setCurrentSoundscape] = useState(null);
  
  // Centralized audio state prevents cutoffs during navigation
  return (
    <AudioContext.Provider value={{ isMuted, setIsMuted, currentSoundscape, setCurrentSoundscape }}>
      {children}
    </AudioContext.Provider>
  );
};
```

### 3. Browser Autoplay Compliance
Modern browsers block autoplay. Always gate audio behind user interaction:
```javascript
const initAudio = () => {
  const audioContext = new AudioContext();
  // Only create AudioContext after user gesture
  document.addEventListener('click', () => {
    if (audioContext.state === 'suspended') {
      audioContext.resume();
    }
  }, { once: true });
};
```

## Audio Asset Guidelines

### File Formats
- **SFX**: MP3 (128kbps) or OGG for broad compatibility
- **Ambient**: AAC or MP3 (96-128kbps) with looping metadata

### Frequency Management
- **Avoid**: High-mid frequencies (2-5kHz) that cause fatigue
- **Prefer**: Low-mid warmth (200-800Hz) for ambient layers
- **UI SFX**: Bright but short transients (4-8kHz) for clarity

### Volume Levels
- **Ambient**: -24dB to -18dB (barely perceptible)
- **Hover SFX**: -12dB to -9dB (subtle)
- **Click/Success**: -6dB to -3dB (clear confirmation)

## Accessibility Considerations

1. **Respect `prefers-reduced-motion`**: Disable all audio if user has motion sensitivity
2. **Screen Reader Compatibility**: Ensure mute controls are keyboard accessible and announced
3. **Visual Indicators**: Pair audio feedback with visual cues (ripples, color shifts)

## Performance Optimization

- **Pre-load Critical SFX**: Load hover/click sounds on page load
- **Lazy Load Ambient**: Only fetch soundscapes when user scrolls to relevant section
- **Audio Sprites**: Combine multiple SFX into single file to reduce HTTP requests
- **Web Audio API**: Use for advanced mixing and real-time effects (reverb, filters)

## Verification Checklist
- [ ] Global mute control is visible and functional
- [ ] No audio plays before user interaction
- [ ] All SFX are <500ms and harmonically coherent
- [ ] Ambient soundscapes crossfade smoothly (no pops/clicks)
- [ ] Total audio payload <500KB for initial page load
- [ ] Keyboard accessible controls
- [ ] Respects `prefers-reduced-motion`

> [!IMPORTANT]
> Audio should feel like a natural extension of the UI, not a gimmick. When in doubt, err on the side of subtlety.
