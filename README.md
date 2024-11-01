# swift-share-link

Swift package that abstracts the `UIActivityViewController` into a reactive view-modifier.

## How to Use

Add a sharelink

```swift
.shareLink(item: $destination)
```

## Example

<table>
<tr>
<th>
Preview
</th>
<th>
Code
</th>
</tr>

<tr>

<td>
<video src="https://github.com/user-attachments/assets/4a40b50c-c888-413f-a544-8a1bd24c7773">
</td>

<td>

```swift
struct ContentView: View {
  @State var destination: URL?
  @State var inFlight = false
  
  var body: some View {
    Button {
      Task {
        self.inFlight = true
        self.destination = try await createURL(with: Data())
        self.inFlight = false
      }
    } label: {
      if self.inFlight {
        ProgressView()
      } else {
        Text("Share")
      }
    }
    .shareLink(item: $destination)
  }
}

@Sendable func createURL(with data: Data) async throws -> URL {
  try await Task.sleep(for: .seconds(1))
  return URL(string: "https://www.apple.com")!
}
```

</td>

</tr>
</table>
