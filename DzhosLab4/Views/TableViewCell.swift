import UIKit
import RxDataSources
import RxSwift

class TableViewCell: UITableViewCell {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.addSubview(buildView)
        setupConstraints()
    }
    
    func configure(element: ForecastElement) {
        self.textView.text = "Time: \(element.time) Temp: \(element.temp)"
                        + "\nWind \(element.wind) Weather \(element.weatherName)"
        self.picView.image = UIImage(data: element.weatherIcon)
    }
    
    private lazy var textView: UILabel = {
        let textView = UILabel()
        textView.numberOfLines = 2
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    
    private lazy var picView: UIImageView = {
        let picView = UIImageView()
        picView.contentMode = .scaleAspectFit
        
        picView.translatesAutoresizingMaskIntoConstraints = false
        return picView
    }()
    
    private lazy var buildView: UIView = {
        let stackView = UIStackView()
        stackView.addArrangedSubview(textView)
        stackView.addArrangedSubview(picView)

        stackView.spacing = 10
        stackView.axis = .horizontal
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            buildView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            buildView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            buildView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            buildView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            buildView.topAnchor.constraint(equalTo: contentView.topAnchor),
            buildView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            // textView.heightAnchor.constraint(equalToConstant: 50),
            picView.widthAnchor.constraint(equalToConstant: 50)
        ])
    }
}
