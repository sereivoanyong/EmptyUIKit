//
//  EmptyView.swift
//
//  Created by Sereivoan Yong on 4/30/21.
//

import UIKit

public protocol EmptyViewDataSource: AnyObject {

  func emptyView(_ emptyView: EmptyView, configureContentFor state: EmptyView.State)
  func emptyViewPrepareForReuse(_ emptyView: EmptyView)
}

extension EmptyViewDataSource {

  public func emptyViewPrepareForReuse(_ emptyView: EmptyView) {
    emptyView.reset()
  }
}

extension EmptyView {

  public enum State: Equatable {

    case empty
    case error(Error)

    public static func == (lhs: Self, rhs: Self) -> Bool {
      switch (lhs, rhs) {
      case (.empty, .empty):
        return true
      case (.empty, .error), (.error, .empty):
        return false
      case (.error(let lhs), .error(let rhs)):
        return AnyEquatableError(error: lhs) == AnyEquatableError(error: rhs)
      }
    }
  }
}

open class EmptyView: UIView {

  // This is not needed if the empty view is attached to either `UICollectionView` or `UITableView`,
  // and the provided state is never `.error`
  open weak var stateProvider: EmptyViewStateProviding?

  open weak var dataSource: EmptyViewDataSource?

  open private(set) var state: State? {
    didSet {
      prepareForReuse()
      if let state {
        dataSource?.emptyView(self, configureContentFor: state)
        reloadHiddenStates()
        isHidden = false
      } else {
        isHidden = true
      }
    }
  }

  // MARK: Public Properties

  public let stackView: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .vertical
    stackView.distribution = .fill
    stackView.alignment = .center
    stackView.spacing = 8
    return stackView
  }()

  private var _imageView: UIImageView?
  lazy open private(set) var imageView: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .scaleAspectFit
    imageView.tintColor = .tertiaryLabel
    imageView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 48)
    stackView.insertArrangedSubview(imageView, at: 0)
    _imageView = imageView
    return imageView
  }()

  private var _textLabel: UILabel?
  lazy open private(set) var textLabel: UILabel = {
    let label = UILabel()
    label.font = .systemFont(ofSize: 22, weight: .semibold)
    label.textAlignment = .center
    label.textColor = .secondaryLabel
    label.numberOfLines = 0
    if let _imageView, let index = stackView.arrangedSubviews.firstIndex(of: _imageView) {
      stackView.insertArrangedSubview(label, at: index + 1)
    } else {
      stackView.insertArrangedSubview(label, at: 0)
    }
    _textLabel = label
    return label
  }()

  private var _secondaryTextLabel: UILabel?
  lazy open private(set) var secondaryTextLabel: UILabel = {
    let label = UILabel()
    label.font = .systemFont(ofSize: 14)
    label.textAlignment = .center
    label.textColor = .tertiaryLabel
    label.numberOfLines = 0
    if let _textLabel, let index = stackView.arrangedSubviews.firstIndex(of: _textLabel) {
      stackView.insertArrangedSubview(label, at: index + 1)
    } else if let _imageView, let index = stackView.arrangedSubviews.firstIndex(of: _imageView) {
      stackView.insertArrangedSubview(label, at: index + 1)
    } else {
      stackView.insertArrangedSubview(label, at: 0)
    }
    _secondaryTextLabel = label
    return label
  }()

  private var _button: UIButton?
  lazy open private(set) var button: UIButton = {
    let button = UIButton(type: .system)
    stackView.addArrangedSubview(button)
    _button = button
    return button
  }()

  open var image: UIImage? {
    get { return _imageView?.image }
    set {
      if let _imageView {
        _imageView.image = newValue
      } else if let newValue {
        imageView.image = newValue
      }
    }
  }

  open var text: String? {
    get { return _textLabel?.text }
    set {
      if let _textLabel {
        _textLabel.text = newValue
      } else if let newValue, !newValue.isEmpty {
        textLabel.text = newValue
      }
    }
  }

  open var attributedText: NSAttributedString? {
    get { return _textLabel?.attributedText }
    set {
      if let _textLabel {
        _textLabel.attributedText = newValue
      } else if let newValue {
        textLabel.attributedText = newValue
      }
    }
  }

  open var secondaryText: String? {
    get { return _secondaryTextLabel?.text }
    set {
      if let _secondaryTextLabel {
        _secondaryTextLabel.text = newValue
      } else if let newValue, !newValue.isEmpty {
        secondaryTextLabel.text = newValue
      }
    }
  }

  open var secondaryAttributedText: NSAttributedString? {
    get { return _secondaryTextLabel?.attributedText }
    set {
      if let _secondaryTextLabel {
        _secondaryTextLabel.attributedText = newValue
      } else if let newValue {
        secondaryTextLabel.attributedText = newValue
      }
    }
  }

  // MARK: Initializers

  public override init(frame: CGRect = .zero) {
    super.init(frame: frame)
    commonInit()
  }

  public required init?(coder: NSCoder) {
    super.init(coder: coder)
    commonInit()
  }

  private func commonInit() {
    isHidden = true

    addSubview(stackView)

    stackView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      stackView.topAnchor.constraint(equalTo: topAnchor),
      stackView.leftAnchor.constraint(equalTo: leftAnchor),
      bottomAnchor.constraint(equalTo: stackView.bottomAnchor),
      rightAnchor.constraint(equalTo: stackView.rightAnchor)
    ])
  }

  // MARK: Public

  // This is called automatically if the empty view is either `UICollectionView` or `UITableView`
  open func reload() {
    if let stateProvider = stateProvider ?? superview as? EmptyViewStateProviding {
      state = stateProvider.state(for: self)
    } else {
      state = nil
    }
  }

  open func prepareForReuse() {
    if let dataSource {
      dataSource.emptyViewPrepareForReuse(self)
    } else {
      reset()
    }
  }

  // MARK: Internal

  @usableFromInline
  func reset() {
    if let _imageView {
      _imageView.image = nil
    }
    if let _textLabel {
      _textLabel.text = nil
      _textLabel.attributedText = nil
    }
    if let _secondaryTextLabel {
      _secondaryTextLabel.text = nil
      _secondaryTextLabel.attributedText = nil
    }
    if let _button {
      _button.setTitle(nil, for: .normal)
      _button.setAttributedTitle(nil, for: .normal)
      _button.setImage(nil, for: .normal)
      _button.setBackgroundImage(nil, for: .normal)
      _button.setPreferredSymbolConfiguration(nil, forImageIn: .normal)
      if #available(iOS 15.0, *) {
        _button.configuration = nil
      }
    }
    reloadHiddenStates()
  }

  // MARK: Private

  private func reloadHiddenStates() {
    if let _imageView {
      _imageView.isHidden = _imageView.image == nil
    }
    if let _textLabel {
      _textLabel.isHidden = _textLabel.text == nil && _textLabel.attributedText == nil
    }
    if let _secondaryTextLabel {
      _secondaryTextLabel.isHidden = _secondaryTextLabel.text == nil && _secondaryTextLabel.attributedText == nil
    }
    if let _button {
      _button.isHidden = !_button.hasContent
    }
  }
}

extension UIButton {

  fileprivate var hasContent: Bool {
    if currentTitle != nil {
      return true
    }
    if currentAttributedTitle != nil {
      return true
    }
    if currentImage != nil {
      return true
    }
    if currentBackgroundImage != nil {
      return true
    }
    if #available(iOS 15.0, *), configuration != nil {
      return true
    }
    return false
  }
}
