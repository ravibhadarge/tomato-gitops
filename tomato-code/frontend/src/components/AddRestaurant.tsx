import { useState } from "react";
import { useAppData } from "../context/AppContext";
import toast from "react-hot-toast";
import axios from "axios";
import { restaurantService } from "../main";
import { BiMapPin, BiUpload } from "react-icons/bi";

interface props {
  fetchMyRestaurant: () => Promise<void>;
}

const AddRestaurant = ({ fetchMyRestaurant }: props) => {
  const [name, setName] = useState("");
  const [description, setDescription] = useState("");
  const [phone, setPhone] = useState("");
  const [image, setImage] = useState<File | null>(null);
  const [submitting, setSubmitting] = useState(false);

  const { loadingLocation, location } = useAppData();

  const handleSubmit = async () => {
    if (!name.trim()) {
      toast.error("Restaurant name is required");
      return;
    }

    if (!phone.trim()) {
      toast.error("Contact number is required");
      return;
    }

    if (!description.trim()) {
      toast.error("Restaurant description is required");
      return;
    }

    if (!image) {
      toast.error("Restaurant image is required");
      return;
    }

    if (loadingLocation) {
      toast.error("Please wait while we fetch your location");
      return;
    }

    if (!location) {
      toast.error("Location is required. Please allow location access.");
      return;
    }

    try {
      setSubmitting(true);

      const formData = new FormData();
      formData.append("name", name.trim());
      formData.append("description", description.trim());
      formData.append("phone", phone.trim());
      formData.append("latitude", String(location.latitude));
      formData.append("longitude", String(location.longitude));
      formData.append("formattedAddress", location.formattedAddress);
      formData.append("file", image);

      await axios.post(
        `${restaurantService}/api/restaurant/new`,
        formData,
        {
          headers: {
            Authorization: `Bearer ${localStorage.getItem("token")}`,
          },
        }
      );

      toast.success("Restaurant Added successfully");
      await fetchMyRestaurant();
    } catch (error: any) {
      console.error("Add restaurant error:", error);
      toast.error(
        error?.response?.data?.message || "Failed to add restaurant"
      );
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <div className="min-h-screen bg-gray-50 px-4 py-6">
      <div className="mx-auto max-w-lg rounded-xl bg-white p-6 shadow-sm space-y-5">
        <h1 className="text-xl font-semibold">Add Your Restaurant</h1>

        <input
          type="text"
          placeholder="Restaurant name"
          value={name}
          onChange={(e) => setName(e.target.value)}
          className="w-full rounded-lg border px-4 py-2 text-sm outline-none"
        />

        <input
          type="tel"
          placeholder="Contact Number"
          value={phone}
          onChange={(e) => setPhone(e.target.value)}
          className="w-full rounded-lg border px-4 py-2 text-sm outline-none"
        />

        <textarea
          placeholder="Restaurant Description"
          value={description}
          onChange={(e) => setDescription(e.target.value)}
          className="w-full rounded-lg border px-4 py-2 text-sm outline-none"
        />

        <label className="flex cursor-pointer items-center gap-3 rounded-lg border p-4 text-sm text-gray-600 hover:bg-gray-50">
          <BiUpload className="h-5 w-5 text-red-500" />
          {image ? image.name : "Upload restaurant image"}
          <input
            type="file"
            accept="image/*"
            hidden
            onChange={(e) => setImage(e.target.files?.[0] || null)}
          />
        </label>

        <div className="flex items-start gap-3 rounded-lg border p-4">
          <BiMapPin className="mt-0.5 h-5 w-5 text-red-500" />
          <div className="text-sm">
            {loadingLocation
              ? "Fetching your location..."
              : location?.formattedAddress || "Location not available"}
          </div>
        </div>

        <button
          className="w-full rounded-lg py-3 text-sm font-semibold text-white bg-[#e23744] disabled:opacity-50"
          disabled={submitting || loadingLocation}
          onClick={handleSubmit}
        >
          {loadingLocation
            ? "Fetching your location..."
            : submitting
            ? "Submitting..."
            : "Add Restaurant"}
        </button>
      </div>
    </div>
  );
};

export default AddRestaurant;
