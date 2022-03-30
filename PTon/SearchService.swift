import Foundation
//MARK: - 식품 영양 성분 db

struct Response: Codable {
    let success: Bool
    let result: String
    let message: String
}

func requestGet(url:String,completion:@escaping(Bool,Any)->Void){
    guard let url = URL(string: url) else{
        print("Error cannot create URL")
        return
    }
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    request.timeoutInterval = TimeInterval.infinity
    
    print("Url in Example ::: \(url)")
    let session = URLSession(configuration: .default)
    let task = session.dataTask(with: request){ data,response,error in
               
        if let response = response as? HTTPURLResponse {
            print("Response Code ::: \(response.statusCode)")
        }
        
        guard let response = response as? HTTPURLResponse, (200 ..< 300) ~= response.statusCode else {
            print("Error: HTTP request failed")
            return
        }

        print("response ::: \(response)")
        
        guard let data = data else{return}
        print(String(data: data, encoding: .utf8))
        
        guard let output = try? JSONDecoder().decode(Response.self, from: data) else {
            print("Error: JSON Data Parsing failed")
            return
        }

        completion(true, output.result)

    }
    task.resume()
}
