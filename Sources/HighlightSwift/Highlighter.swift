import Foundation
#if canImport(AppKit)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

public struct HighlightTheme: Hashable, Sendable {
  public let rawValue: String

  public init(_ name: String) {
    rawValue = name
  }

  // MARK: - Top-level themes

  public static let _1cLight = HighlightTheme("1c-light")
  public static let a11yDark = HighlightTheme("a11y-dark")
  public static let a11yLight = HighlightTheme("a11y-light")
  public static let agate = HighlightTheme("agate")
  public static let anOldHope = HighlightTheme("an-old-hope")
  public static let androidstudio = HighlightTheme("androidstudio")
  public static let arduinoLight = HighlightTheme("arduino-light")
  public static let arta = HighlightTheme("arta")
  public static let ascetic = HighlightTheme("ascetic")
  public static let atomOneDark = HighlightTheme("atom-one-dark")
  public static let atomOneDarkReasonable = HighlightTheme("atom-one-dark-reasonable")
  public static let atomOneLight = HighlightTheme("atom-one-light")
  public static let brownPaper = HighlightTheme("brown-paper")
  public static let codepenEmbed = HighlightTheme("codepen-embed")
  public static let colorBrewer = HighlightTheme("color-brewer")
  public static let cybertopiaCherry = HighlightTheme("cybertopia-cherry")
  public static let cybertopiaDimmer = HighlightTheme("cybertopia-dimmer")
  public static let cybertopiaIcecap = HighlightTheme("cybertopia-icecap")
  public static let cybertopiaSaturated = HighlightTheme("cybertopia-saturated")
  public static let dark = HighlightTheme("dark")
  public static let default_ = HighlightTheme("default")
  public static let devibeans = HighlightTheme("devibeans")
  public static let docco = HighlightTheme("docco")
  public static let far = HighlightTheme("far")
  public static let felipec = HighlightTheme("felipec")
  public static let foundation = HighlightTheme("foundation")
  public static let github = HighlightTheme("github")
  public static let githubDark = HighlightTheme("github-dark")
  public static let githubDarkDimmed = HighlightTheme("github-dark-dimmed")
  public static let gml = HighlightTheme("gml")
  public static let googlecode = HighlightTheme("googlecode")
  public static let gradientDark = HighlightTheme("gradient-dark")
  public static let gradientLight = HighlightTheme("gradient-light")
  public static let grayscale = HighlightTheme("grayscale")
  public static let hybrid = HighlightTheme("hybrid")
  public static let idea = HighlightTheme("idea")
  public static let intellijLight = HighlightTheme("intellij-light")
  public static let irBlack = HighlightTheme("ir-black")
  public static let isblEditorDark = HighlightTheme("isbl-editor-dark")
  public static let isblEditorLight = HighlightTheme("isbl-editor-light")
  public static let kimbieDark = HighlightTheme("kimbie-dark")
  public static let kimbieLight = HighlightTheme("kimbie-light")
  public static let lightfair = HighlightTheme("lightfair")
  public static let lioshi = HighlightTheme("lioshi")
  public static let magula = HighlightTheme("magula")
  public static let monoBlue = HighlightTheme("mono-blue")
  public static let monokai = HighlightTheme("monokai")
  public static let monokaiSublime = HighlightTheme("monokai-sublime")
  public static let nightOwl = HighlightTheme("night-owl")
  public static let nnfxDark = HighlightTheme("nnfx-dark")
  public static let nnfxLight = HighlightTheme("nnfx-light")
  public static let nord = HighlightTheme("nord")
  public static let obsidian = HighlightTheme("obsidian")
  public static let pandaSyntaxDark = HighlightTheme("panda-syntax-dark")
  public static let pandaSyntaxLight = HighlightTheme("panda-syntax-light")
  public static let paraisoDark = HighlightTheme("paraiso-dark")
  public static let paraisoLight = HighlightTheme("paraiso-light")
  public static let pojoaque = HighlightTheme("pojoaque")
  public static let purebasic = HighlightTheme("purebasic")
  public static let qtcreatorDark = HighlightTheme("qtcreator-dark")
  public static let qtcreatorLight = HighlightTheme("qtcreator-light")
  public static let rainbow = HighlightTheme("rainbow")
  public static let rosePine = HighlightTheme("rose-pine")
  public static let rosePineDawn = HighlightTheme("rose-pine-dawn")
  public static let rosePineMoon = HighlightTheme("rose-pine-moon")
  public static let routeros = HighlightTheme("routeros")
  public static let schoolBook = HighlightTheme("school-book")
  public static let shadesOfPurple = HighlightTheme("shades-of-purple")
  public static let srcery = HighlightTheme("srcery")
  public static let stackoverflowDark = HighlightTheme("stackoverflow-dark")
  public static let stackoverflowLight = HighlightTheme("stackoverflow-light")
  public static let sunburst = HighlightTheme("sunburst")
  public static let tokyoNightDark = HighlightTheme("tokyo-night-dark")
  public static let tokyoNightLight = HighlightTheme("tokyo-night-light")
  public static let tomorrowNightBlue = HighlightTheme("tomorrow-night-blue")
  public static let tomorrowNightBright = HighlightTheme("tomorrow-night-bright")
  public static let vs = HighlightTheme("vs")
  public static let vsDark = HighlightTheme("vs-dark")
  public static let vs2015 = HighlightTheme("vs2015")
  public static let xcode = HighlightTheme("xcode")
  public static let xt256 = HighlightTheme("xt256")

  // MARK: - Base16 themes

  public static let base16_3024 = HighlightTheme("base16/3024")
  public static let base16Apathy = HighlightTheme("base16/apathy")
  public static let base16Apprentice = HighlightTheme("base16/apprentice")
  public static let base16Ashes = HighlightTheme("base16/ashes")
  public static let base16AtelierCave = HighlightTheme("base16/atelier-cave")
  public static let base16AtelierCaveLight = HighlightTheme("base16/atelier-cave-light")
  public static let base16AtelierDune = HighlightTheme("base16/atelier-dune")
  public static let base16AtelierDuneLight = HighlightTheme("base16/atelier-dune-light")
  public static let base16AtelierEstuary = HighlightTheme("base16/atelier-estuary")
  public static let base16AtelierEstuaryLight = HighlightTheme("base16/atelier-estuary-light")
  public static let base16AtelierForest = HighlightTheme("base16/atelier-forest")
  public static let base16AtelierForestLight = HighlightTheme("base16/atelier-forest-light")
  public static let base16AtelierHeath = HighlightTheme("base16/atelier-heath")
  public static let base16AtelierHeathLight = HighlightTheme("base16/atelier-heath-light")
  public static let base16AtelierLakeside = HighlightTheme("base16/atelier-lakeside")
  public static let base16AtelierLakesideLight = HighlightTheme("base16/atelier-lakeside-light")
  public static let base16AtelierPlateau = HighlightTheme("base16/atelier-plateau")
  public static let base16AtelierPlateauLight = HighlightTheme("base16/atelier-plateau-light")
  public static let base16AtelierSavanna = HighlightTheme("base16/atelier-savanna")
  public static let base16AtelierSavannaLight = HighlightTheme("base16/atelier-savanna-light")
  public static let base16AtelierSeaside = HighlightTheme("base16/atelier-seaside")
  public static let base16AtelierSeasideLight = HighlightTheme("base16/atelier-seaside-light")
  public static let base16AtelierSulphurpool = HighlightTheme("base16/atelier-sulphurpool")
  public static let base16AtelierSulphurpoolLight = HighlightTheme("base16/atelier-sulphurpool-light")
  public static let base16Atlas = HighlightTheme("base16/atlas")
  public static let base16Bespin = HighlightTheme("base16/bespin")
  public static let base16BlackMetal = HighlightTheme("base16/black-metal")
  public static let base16BlackMetalBathory = HighlightTheme("base16/black-metal-bathory")
  public static let base16BlackMetalBurzum = HighlightTheme("base16/black-metal-burzum")
  public static let base16BlackMetalDarkFuneral = HighlightTheme("base16/black-metal-dark-funeral")
  public static let base16BlackMetalGorgoroth = HighlightTheme("base16/black-metal-gorgoroth")
  public static let base16BlackMetalImmortal = HighlightTheme("base16/black-metal-immortal")
  public static let base16BlackMetalKhold = HighlightTheme("base16/black-metal-khold")
  public static let base16BlackMetalMarduk = HighlightTheme("base16/black-metal-marduk")
  public static let base16BlackMetalMayhem = HighlightTheme("base16/black-metal-mayhem")
  public static let base16BlackMetalNile = HighlightTheme("base16/black-metal-nile")
  public static let base16BlackMetalVenom = HighlightTheme("base16/black-metal-venom")
  public static let base16Brewer = HighlightTheme("base16/brewer")
  public static let base16Bright = HighlightTheme("base16/bright")
  public static let base16Brogrammer = HighlightTheme("base16/brogrammer")
  public static let base16BrushTrees = HighlightTheme("base16/brush-trees")
  public static let base16BrushTreesDark = HighlightTheme("base16/brush-trees-dark")
  public static let base16Chalk = HighlightTheme("base16/chalk")
  public static let base16Circus = HighlightTheme("base16/circus")
  public static let base16ClassicDark = HighlightTheme("base16/classic-dark")
  public static let base16ClassicLight = HighlightTheme("base16/classic-light")
  public static let base16Codeschool = HighlightTheme("base16/codeschool")
  public static let base16Colors = HighlightTheme("base16/colors")
  public static let base16Cupcake = HighlightTheme("base16/cupcake")
  public static let base16Cupertino = HighlightTheme("base16/cupertino")
  public static let base16Danqing = HighlightTheme("base16/danqing")
  public static let base16Darcula = HighlightTheme("base16/darcula")
  public static let base16DarkViolet = HighlightTheme("base16/dark-violet")
  public static let base16Darkmoss = HighlightTheme("base16/darkmoss")
  public static let base16Darktooth = HighlightTheme("base16/darktooth")
  public static let base16Decaf = HighlightTheme("base16/decaf")
  public static let base16DefaultDark = HighlightTheme("base16/default-dark")
  public static let base16DefaultLight = HighlightTheme("base16/default-light")
  public static let base16Dirtysea = HighlightTheme("base16/dirtysea")
  public static let base16Dracula = HighlightTheme("base16/dracula")
  public static let base16EdgeDark = HighlightTheme("base16/edge-dark")
  public static let base16EdgeLight = HighlightTheme("base16/edge-light")
  public static let base16Eighties = HighlightTheme("base16/eighties")
  public static let base16Embers = HighlightTheme("base16/embers")
  public static let base16EquilibriumDark = HighlightTheme("base16/equilibrium-dark")
  public static let base16EquilibriumGrayDark = HighlightTheme("base16/equilibrium-gray-dark")
  public static let base16EquilibriumGrayLight = HighlightTheme("base16/equilibrium-gray-light")
  public static let base16EquilibriumLight = HighlightTheme("base16/equilibrium-light")
  public static let base16Espresso = HighlightTheme("base16/espresso")
  public static let base16Eva = HighlightTheme("base16/eva")
  public static let base16EvaDim = HighlightTheme("base16/eva-dim")
  public static let base16Flat = HighlightTheme("base16/flat")
  public static let base16Framer = HighlightTheme("base16/framer")
  public static let base16FruitSoda = HighlightTheme("base16/fruit-soda")
  public static let base16Gigavolt = HighlightTheme("base16/gigavolt")
  public static let base16Github = HighlightTheme("base16/github")
  public static let base16GoogleDark = HighlightTheme("base16/google-dark")
  public static let base16GoogleLight = HighlightTheme("base16/google-light")
  public static let base16GrayscaleDark = HighlightTheme("base16/grayscale-dark")
  public static let base16GrayscaleLight = HighlightTheme("base16/grayscale-light")
  public static let base16GreenScreen = HighlightTheme("base16/green-screen")
  public static let base16GruvboxDarkHard = HighlightTheme("base16/gruvbox-dark-hard")
  public static let base16GruvboxDarkMedium = HighlightTheme("base16/gruvbox-dark-medium")
  public static let base16GruvboxDarkPale = HighlightTheme("base16/gruvbox-dark-pale")
  public static let base16GruvboxDarkSoft = HighlightTheme("base16/gruvbox-dark-soft")
  public static let base16GruvboxLightHard = HighlightTheme("base16/gruvbox-light-hard")
  public static let base16GruvboxLightMedium = HighlightTheme("base16/gruvbox-light-medium")
  public static let base16GruvboxLightSoft = HighlightTheme("base16/gruvbox-light-soft")
  public static let base16Hardcore = HighlightTheme("base16/hardcore")
  public static let base16Harmonic16Dark = HighlightTheme("base16/harmonic16-dark")
  public static let base16Harmonic16Light = HighlightTheme("base16/harmonic16-light")
  public static let base16HeetchDark = HighlightTheme("base16/heetch-dark")
  public static let base16HeetchLight = HighlightTheme("base16/heetch-light")
  public static let base16Helios = HighlightTheme("base16/helios")
  public static let base16Hopscotch = HighlightTheme("base16/hopscotch")
  public static let base16HorizonDark = HighlightTheme("base16/horizon-dark")
  public static let base16HorizonLight = HighlightTheme("base16/horizon-light")
  public static let base16HumanoidDark = HighlightTheme("base16/humanoid-dark")
  public static let base16HumanoidLight = HighlightTheme("base16/humanoid-light")
  public static let base16IaDark = HighlightTheme("base16/ia-dark")
  public static let base16IaLight = HighlightTheme("base16/ia-light")
  public static let base16IcyDark = HighlightTheme("base16/icy-dark")
  public static let base16IrBlack = HighlightTheme("base16/ir-black")
  public static let base16Isotope = HighlightTheme("base16/isotope")
  public static let base16Kimber = HighlightTheme("base16/kimber")
  public static let base16LondonTube = HighlightTheme("base16/london-tube")
  public static let base16Macintosh = HighlightTheme("base16/macintosh")
  public static let base16Marrakesh = HighlightTheme("base16/marrakesh")
  public static let base16Materia = HighlightTheme("base16/materia")
  public static let base16Material = HighlightTheme("base16/material")
  public static let base16MaterialDarker = HighlightTheme("base16/material-darker")
  public static let base16MaterialLighter = HighlightTheme("base16/material-lighter")
  public static let base16MaterialPalenight = HighlightTheme("base16/material-palenight")
  public static let base16MaterialVivid = HighlightTheme("base16/material-vivid")
  public static let base16MellowPurple = HighlightTheme("base16/mellow-purple")
  public static let base16MexicoLight = HighlightTheme("base16/mexico-light")
  public static let base16Mocha = HighlightTheme("base16/mocha")
  public static let base16Monokai = HighlightTheme("base16/monokai")
  public static let base16Nebula = HighlightTheme("base16/nebula")
  public static let base16Nord = HighlightTheme("base16/nord")
  public static let base16Nova = HighlightTheme("base16/nova")
  public static let base16Ocean = HighlightTheme("base16/ocean")
  public static let base16Oceanicnext = HighlightTheme("base16/oceanicnext")
  public static let base16OneLight = HighlightTheme("base16/one-light")
  public static let base16Onedark = HighlightTheme("base16/onedark")
  public static let base16OutrunDark = HighlightTheme("base16/outrun-dark")
  public static let base16PapercolorDark = HighlightTheme("base16/papercolor-dark")
  public static let base16PapercolorLight = HighlightTheme("base16/papercolor-light")
  public static let base16Paraiso = HighlightTheme("base16/paraiso")
  public static let base16Pasque = HighlightTheme("base16/pasque")
  public static let base16Phd = HighlightTheme("base16/phd")
  public static let base16Pico = HighlightTheme("base16/pico")
  public static let base16Pop = HighlightTheme("base16/pop")
  public static let base16Porple = HighlightTheme("base16/porple")
  public static let base16Qualia = HighlightTheme("base16/qualia")
  public static let base16Railscasts = HighlightTheme("base16/railscasts")
  public static let base16Rebecca = HighlightTheme("base16/rebecca")
  public static let base16RosPine = HighlightTheme("base16/ros-pine")
  public static let base16RosPineDawn = HighlightTheme("base16/ros-pine-dawn")
  public static let base16RosPineMoon = HighlightTheme("base16/ros-pine-moon")
  public static let base16Sagelight = HighlightTheme("base16/sagelight")
  public static let base16Sandcastle = HighlightTheme("base16/sandcastle")
  public static let base16SetiUi = HighlightTheme("base16/seti-ui")
  public static let base16Shapeshifter = HighlightTheme("base16/shapeshifter")
  public static let base16SilkDark = HighlightTheme("base16/silk-dark")
  public static let base16SilkLight = HighlightTheme("base16/silk-light")
  public static let base16Snazzy = HighlightTheme("base16/snazzy")
  public static let base16SolarFlare = HighlightTheme("base16/solar-flare")
  public static let base16SolarFlareLight = HighlightTheme("base16/solar-flare-light")
  public static let base16SolarizedDark = HighlightTheme("base16/solarized-dark")
  public static let base16SolarizedLight = HighlightTheme("base16/solarized-light")
  public static let base16Spacemacs = HighlightTheme("base16/spacemacs")
  public static let base16Summercamp = HighlightTheme("base16/summercamp")
  public static let base16SummerfruitDark = HighlightTheme("base16/summerfruit-dark")
  public static let base16SummerfruitLight = HighlightTheme("base16/summerfruit-light")
  public static let base16SynthMidnightTerminalDark = HighlightTheme("base16/synth-midnight-terminal-dark")
  public static let base16SynthMidnightTerminalLight = HighlightTheme("base16/synth-midnight-terminal-light")
  public static let base16Tango = HighlightTheme("base16/tango")
  public static let base16Tender = HighlightTheme("base16/tender")
  public static let base16Tomorrow = HighlightTheme("base16/tomorrow")
  public static let base16TomorrowNight = HighlightTheme("base16/tomorrow-night")
  public static let base16Twilight = HighlightTheme("base16/twilight")
  public static let base16UnikittyDark = HighlightTheme("base16/unikitty-dark")
  public static let base16UnikittyLight = HighlightTheme("base16/unikitty-light")
  public static let base16Vulcan = HighlightTheme("base16/vulcan")
  public static let base16Windows10 = HighlightTheme("base16/windows-10")
  public static let base16Windows10Light = HighlightTheme("base16/windows-10-light")
  public static let base16Windows95 = HighlightTheme("base16/windows-95")
  public static let base16Windows95Light = HighlightTheme("base16/windows-95-light")
  public static let base16WindowsHighContrast = HighlightTheme("base16/windows-high-contrast")
  public static let base16WindowsHighContrastLight = HighlightTheme("base16/windows-high-contrast-light")
  public static let base16WindowsNt = HighlightTheme("base16/windows-nt")
  public static let base16WindowsNtLight = HighlightTheme("base16/windows-nt-light")
  public static let base16Woodland = HighlightTheme("base16/woodland")
  public static let base16XcodeDusk = HighlightTheme("base16/xcode-dusk")
  public static let base16Zenburn = HighlightTheme("base16/zenburn")

  /// Returns all available theme names by scanning the bundled styles directory.
  public static func allThemes() -> [HighlightTheme] {
    guard let stylesURL = Bundle.module.url(forResource: "styles", withExtension: nil, subdirectory: "Resources") else {
      return []
    }
    var names = Set<String>()

    func scan(directory: URL, prefix: String = "") {
      guard let files = try? FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil) else { return }
      for file in files {
        var isDir: ObjCBool = false
        if FileManager.default.fileExists(atPath: file.path, isDirectory: &isDir), isDir.boolValue {
          scan(directory: file, prefix: file.lastPathComponent + "/")
        } else if file.pathExtension == "css" {
          let name = file.deletingPathExtension().lastPathComponent
          if !name.hasSuffix(".min") {
            names.insert(prefix + name)
          }
        }
      }
    }

    scan(directory: stylesURL)
    return names.sorted().map { HighlightTheme($0) }
  }
}

public enum HighlightError: Error {
  case engineInitFailed
  case highlightFailed
  case themeNotFound
  case languageNotSupported
}

public struct HighlightResult {
  public let attributedString: NSAttributedString
  public let backgroundColor: PlatformColor?
}

public enum Highlighter {
  private static let cache = HighlightCache.shared

  public static func highlight(
    _ code: String,
    language: String,
    theme: HighlightTheme = .default_
  ) throws -> NSAttributedString {
    let html = try cachedHighlight(code, language: language)
    let styles = try cachedStyles(theme)
    return AttributedStringBuilder.build(from: html, styles: styles)
  }

  public static func highlightWithBackground(
    _ code: String,
    language: String,
    theme: HighlightTheme = .default_
  ) throws -> HighlightResult {
    let html = try cachedHighlight(code, language: language)
    let styles = try cachedStyles(theme)
    let attrStr = AttributedStringBuilder.build(from: html, styles: styles)
    let bg = styles["_background"]?.effectiveColor
    return HighlightResult(attributedString: attrStr, backgroundColor: bg)
  }

  public static func listLanguages() -> [String] {
    (try? HighlightEngine.shared.listLanguages()) ?? []
  }

  /// Clear all internal caches.
  public static func clearCache() {
    cache.clearAll()
  }

  // MARK: - Internal cached helpers

  private static func cachedHighlight(_ code: String, language: String) throws -> String {
    if let cached = cache.cachedHTML(code: code, language: language) {
      return cached
    }
    let html = try HighlightEngine.shared.highlight(code, language: language)
    cache.setHTML(html, code: code, language: language)
    return html
  }

  private static func cachedStyles(_ theme: HighlightTheme) throws -> [String: TokenStyle] {
    if let cached = cache.cachedStyles(theme) {
      return cached
    }
    let styles = try ThemeParser.parseStyles(theme: theme)
    cache.setStyles(styles, for: theme)
    return styles
  }
}
